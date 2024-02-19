type request
type response<'data, 'error> = {
  json: unit => Promise.Js.t<'data, 'error>,
  status: int,
  url: string,
  ok: bool,
}
type error<'data, 'error> = {
  response: option<response<'data, 'error>>,
  request: option<request>,
  name: string,
}

type httpMethod =
  | GET
  | POST
  | PUT
  | HEAD
  | DELETE
  | PATCH

type retryMethod =
  | GET
  | PUT
  | HEAD
  | DELETE
  | OPTIONS
  | TRACE

type retryOptions = {
  limit?: int,
  methods?: array<retryMethod>,
  statusCodes?: array<int>,
  backoffLimit?: int,
  delay?: int => float,
}

type retryCallbackParams = {
  request: request,
  retryCount: int,
}

type beforeRequestCallback = request => unit
type beforeRetryCallback = retryCallbackParams => unit
type beforeErrorCallback<'data, 'error> = error<'data, 'error> => error<'data, 'error>
type responseOptions

@unboxed
type afterResponseCallbackResponse<'data, 'error> =
  | Sync(response<'data, 'error>)
  | Async(promise<response<'data, 'error>>)

type afterResponseCallback<'responseData, 'error> = (
  request,
  responseOptions,
  response<'responseData, 'error>,
) => afterResponseCallbackResponse<'responseData, 'error>

type hooks<'errorData, 'responseData, 'error> = {
  beforeRequest?: array<beforeRequestCallback>,
  beforeRetry?: array<beforeRetryCallback>,
  beforeError?: array<beforeErrorCallback<'errorData, 'error>>,
  afterResponse?: array<afterResponseCallback<'responseData, 'error>>,
}

@unboxed
type retry =
  | Int(int)
  | Options(retryOptions)

type rec onDownloadProgress = (progress, Js.TypedArray2.Uint8Array.t) => unit
and progress = {
  percent: int,
  transferredBytes: int,
  totalBytes: int,
}

module Headers = {
  type t

  external fromObj: Js.t<{..}> => t = "%identity"
  external fromDict: Js.Dict.t<string> => t = "%identity"
}

type requestOptions<'json, 'searchParams, 'errorData, 'responseData, 'responseError> = {
  prefixUrl?: string,
  method?: httpMethod,
  json?: 'json,
  searchParams?: 'searchParams,
  retry?: retry,
  timeout?: int,
  throwHttpErrors?: bool,
  hooks?: hooks<'errorData, 'responseData, 'responseError>,
  onDownloadProgress?: onDownloadProgress,
  parseJson?: string => Js.Json.t,
  headers?: Headers.t,
}

@module("ky")
external fetch: (
  string,
  requestOptions<'json, 'searchParams, 'errorData, 'responseData, 'responseError>,
) => response<'data, 'responseError> = "default"

@module("ky") @scope("default")
external get: (
  string,
  ~options: requestOptions<'json, 'searchParams, 'errorData, 'responseData, 'responseError>=?,
) => response<'data, 'responseError> = "get"
@module("ky") @scope("default")
external post: (
  string,
  ~options: requestOptions<'json, 'searchParams, 'errorData, 'responseData, 'responseError>=?,
) => response<'data, 'responseError> = "post"
@module("ky") @scope("default")
external put: (
  string,
  ~options: requestOptions<'json, 'searchParams, 'errorData, 'responseData, 'responseError>=?,
) => response<'data, 'responseError> = "put"
@module("ky") @scope("default")
external patch: (
  string,
  ~options: requestOptions<'json, 'searchParams, 'errorData, 'responseData, 'responseError>=?,
) => response<'data, 'responseError> = "patch"
@module("ky") @scope("default")
external head: (
  string,
  ~options: requestOptions<'json, 'searchParams, 'errorData, 'responseData, 'responseError>=?,
) => response<'data, 'responseError> = "head"
@module("ky") @scope("default")
external delete: (
  string,
  ~options: requestOptions<'json, 'searchParams, 'errorData, 'responseData, 'responseError>=?,
) => response<'data, 'responseError> = "delete"

module Instance = {
  type t

  @module("ky") @scope("default")
  external create: requestOptions<
    'json,
    'searchParams,
    'errorData,
    'responseData,
    'responseError,
  > => t = "create"

  @send
  external get: (
    t,
    string,
    ~options: requestOptions<'json, 'searchParams, 'errorData, 'responseData, 'responseError>=?,
  ) => response<'data, 'responseError> = "get"
  @send
  external post: (
    t,
    string,
    ~options: requestOptions<'json, 'searchParams, 'errorData, 'responseData, 'responseError>=?,
  ) => response<'data, 'responseError> = "post"
  @send
  external put: (
    t,
    string,
    ~options: requestOptions<'json, 'searchParams, 'errorData, 'responseData, 'responseError>=?,
  ) => response<'data, 'responseError> = "put"
  @send
  external patch: (
    t,
    string,
    ~options: requestOptions<'json, 'searchParams, 'errorData, 'responseData, 'responseError>=?,
  ) => response<'data, 'responseError> = "patch"
  @send
  external head: (
    t,
    string,
    ~options: requestOptions<'json, 'searchParams, 'errorData, 'responseData, 'responseError>=?,
  ) => response<'data, 'responseError> = "head"
  @send
  external delete: (
    t,
    string,
    requestOptions<'json, 'searchParams, 'errorData, 'responseData, 'responseError>,
  ) => response<'data, 'responseError> = "delete"

  @send
  external extend: (
    t,
    requestOptions<'json, 'searchParams, 'errorData, 'responseData, 'responseError>,
  ) => t = "extend"
}
