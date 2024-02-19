open RescriptBun
open RescriptBun.Globals
open Test

let wait = ms => {
  open RescriptCore
  Promise.make((resolve, _) => setTimeout(() => resolve(), ms)->ignore)
}

let retry = ref(0)

@module("bun:test")
external mock: (unit => unit) => unit => unit = "mock"

let afterResponseMock = mock(() => ())

@val
external jsonResponse: (
  'a,
  ~options: RescriptBun.Globals.Response.responseInit=?,
) => RescriptBun.Globals.Response.t = "Response.json"

let server = Bun.serve({
  fetch: async (request, _server) => {
    let url = URL.make(request->Globals.Request.url)
    switch url->Globals.URL.pathname {
    | "/" => jsonResponse({"test": 1})
    | "/afterResponse" => {
        afterResponseMock()
        jsonResponse({"test": 1})
      }
    | "/extend/test" => jsonResponse({"test": 1})
    | "/method" => jsonResponse({"method": request->Globals.Request.method})
    | "/timeout" => {
        await wait(500)
        jsonResponse({"test": 1})
      }
    | "/json" => {
        let data = await request->Globals.Request.json
        jsonResponse(data)
      }
    | "/retry" =>
      if retry.contents === 0 {
        retry := retry.contents + 1
        jsonResponse("busy !", ~options={status: 429})
      } else {
        jsonResponse({"retryCount": retry.contents})
      }
    | _ => jsonResponse(`404`, ~options={status: 404})
    }
  },
})

let port =
  server
  ->Bun.Server.port
  ->RescriptCore.Int.toString

let mockBasePath = `http://localhost:${port}`

type jsonMethod = {method: Ky.httpMethod}
describe("HTTP methods imports", () => {
  test("GET", () => {
    Ky.get("method", ~options={prefixUrl: mockBasePath}).json()
    ->Promise.Js.toResult
    ->Promise.tapOk(
      ({method}) => {
        expect(method)->Expect.toBe(GET)
      },
    )
    ->ignore
  })
  test("POST", () => {
    Ky.post("method", ~options={prefixUrl: mockBasePath}).json()
    ->Promise.Js.toResult
    ->Promise.tapOk(
      ({method}) => {
        expect(method)->Expect.toBe(POST)
      },
    )
    ->ignore
  })
  test("PUT", () => {
    Ky.put("method", ~options={prefixUrl: mockBasePath}).json()
    ->Promise.Js.toResult
    ->Promise.tapOk(
      ({method}) => {
        expect(method)->Expect.toBe(PUT)
      },
    )
    ->ignore
  })
  test("PATCH", () => {
    Ky.patch("method", ~options={prefixUrl: mockBasePath}).json()
    ->Promise.Js.toResult
    ->Promise.tapOk(
      ({method}) => {
        expect(method)->Expect.toBe(PATCH)
      },
    )
    ->ignore
  })
  test("DELETE", () => {
    Ky.delete("method", ~options={prefixUrl: mockBasePath}).json()
    ->Promise.Js.toResult
    ->Promise.tapOk(
      ({method}) => {
        expect(method)->Expect.toBe(DELETE)
      },
    )
    ->ignore
  })
})

type jsonData = {test: int, randomStr: string}
describe("Configuration", () => {
  test("Simple fetch", () => {
    Ky.fetch("", {prefixUrl: mockBasePath, method: GET}).json()
    ->Promise.Js.toResult
    ->Promise.tapOk(
      response => {
        expect(response["test"])->Expect.toBe(1)
      },
    )
    ->ignore
  })

  test("Json", () => {
    let data = {
      test: 1,
      randomStr: "test",
    }

    Ky.post("json", ~options={prefixUrl: mockBasePath, json: data}).json()
    ->Promise.Js.toResult
    ->Promise.tapOk(
      (response: jsonData) => {
        expect(response.test)->Expect.toBe(1)
      },
    )
    ->ignore
  })

  test("Custom retry", () => {
    Ky.fetch(`retry`, {prefixUrl: mockBasePath, method: GET, retry: Int(1)}).json()
    ->Promise.Js.toResult
    ->Promise.tapOk(
      response => {
        expect(response["retryCount"])->Expect.toBe(1)
      },
    )
    ->ignore
  })

  test("Custom timeout", () => {
    Ky.fetch(`timeout`, {prefixUrl: mockBasePath, method: GET, timeout: 100}).json()
    ->Promise.Js.toResult
    ->Promise.tapError(
      err => {
        let err: Ky.error<unit, unit> = err->Obj.magic
        expect(err.name)->Expect.toBe("TimeoutError")
      },
    )
    ->ignore
  })
})

describe("Instance", () => {
  let instance = Ky.Instance.create({prefixUrl: mockBasePath})

  test("Simple fetch", () => {
    (instance->Ky.Instance.get("")).json()
    ->Promise.Js.toResult
    ->Promise.tapOk(
      response => {
        expect(response["test"])->Expect.toBe(1)
      },
    )
    ->ignore
  })
  test("Extend", () => {
    let extendedInstance = instance->Ky.Instance.extend({
      prefixUrl: `${mockBasePath}/extend`,
      headers: Ky.Headers.fromObj({
        "custom-header": "test",
      }),
    })

    (extendedInstance->Ky.Instance.get("test")).json()
    ->Promise.Js.toResult
    ->Promise.tapOk(
      response => {
        expect(response["test"])->Expect.toBe(1)
      },
    )
    ->ignore
  })
})

describe("Hooks", () => {
  let instance = Ky.Instance.create({
    prefixUrl: mockBasePath,
    hooks: {
      afterResponse: [
        (_request, _responseOptions, _response) => {
          Ky.Async(
            Ky.get(
              "afterResponse",
              ~options={prefixUrl: mockBasePath},
            ).json()->Promise.Js.toBsPromise,
          )
        },
      ],
    },
  })

  test("Async", () => {
    (instance->Ky.Instance.get("")).json()
    ->Promise.Js.toResult
    ->Promise.tapOk(
      response => {
        expect(response["test"])->Expect.toBe(1)
        expect((afterResponseMock->Obj.magic: string))->Expect.toHaveBeenCalled
      },
    )
    ->ignore
  })
})
