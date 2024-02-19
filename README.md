# rescript-ky-promise

ReScript bindings for [ky HTTP client](https://github.com/sindresorhus/ky) (targeted version : `~1.2.0`) with [rescript-promise](https://github.com/DCKT/rescript-promise) module.

## Setup

1. Install the module

```bash
bun install @dck/rescript-ky-promise
# or
yarn install @dck/rescript-ky-promise
# or
npm install @dck/rescript-ky-promise
```

2. Add it to your `rescript.json` config

```json
{
  "bsc-dependencies": ["@dck/rescript-ky-promise"]
}
```

## Usage

The functions can be accessed through `Ky` module.

```rescript
type data = {anything: string}

let fetchSomething = async () => {
  try {
    let response: data = await Ky.fetch("test", {prefixUrl: "https://fake.com", method: GET}).json()
    // handle response data
  } catch {
    | JsError(err) => {
      // handle err
      Js.log(err)
    }
  }
}
```

Use shortcut method :

```rescript
type data = {anything: string}

let fetchSomething = async () => {
  try {
    let response: data = await Ky.get("test", {prefixUrl: "https://fake.com"}).json()
    // handle response data
  } catch {
    | JsError(err) => {
      // handle err
      Js.log(err)
    }
  }
}
```

### Instance

```rescript
let instance = Ky.Instance.create({prefixUrl: "https://fake.com"})

type data = {anything: string}

let fetchSomething = async () => {
  try {
    let response: data = await (instance->Ky.Instance.get("test")).json()
    // handle response data
  } catch {
    | JsError(err) => {
      // handle err
      Js.log(err)
    }
  }
}
```

### Extend

```rescript
let instance = Ky.Instance.create({prefixUrl: "https://fake.com"})
let extendedInstance = instance->Ky.Instance.extend({
  prefixUrl: `${mockBasePath}/extend`,
  headers: Ky.Headers.fromObj({
    "custom-header": "test",
  }),
})

type data = {anything: string}

let fetchSomething = async () => {
  try {
    let response: data = await (extendedInstance->Ky.Instance.get("test")).json()
    // handle response data
  } catch {
    | JsError(err) => {
      // handle err
      Js.log(err)
    }
  }
}
```
