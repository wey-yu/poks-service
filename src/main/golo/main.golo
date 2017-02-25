module poks.service

import http
import JSON
import gololang.Async
import gololang.concurrent.workers.WorkerEnvironment
import gololang.Errors
import spark.Spark
import spark.augmentations

function main = |args| {

  if (System.getenv(): get("SERVICE_CREDENTIALS") is null) { raise("😡 no services credentials") }
  if (System.getenv(): get("PORT") is null) { raise("😡 no http port") }
  if (System.getenv(): get("EXPOSED_PORT") is null) { raise("😡 no exposed http port") }
  if (System.getenv(): get("SERVER_URL") is null) { raise("😡 no discovery server url") }
  if (System.getenv(): get("SERVICE_BASE_URL") is null) { raise("😡 no service base url") }
  if (System.getenv(): get("SERVICE_NAME") is null) { raise("😡 no service name") }
  if (System.getenv(): get("SERVICE_ID") is null) { raise("😡 no service id") }
  if (System.getenv(): get("SERVICE_VERSION") is null) { raise("😡 no service version") }

  let port =  Integer.parseInt(System.getenv(): get("PORT"))
  let exposedPort = Integer.parseInt(System.getenv(): get("EXPOSED_PORT"))
  let env = WorkerEnvironment.builder(): withCachedThreadPool()

  let serverUrl = System.getenv(): get("SERVER_URL")

  let serviceBaseUrl = System.getenv(): get("SERVICE_BASE_URL") + ":" + exposedPort

  let serviceName = System.getenv(): get("SERVICE_NAME")
  let serviceId = System.getenv(): get("SERVICE_ID")
  let serviceVersion = System.getenv(): get("SERVICE_VERSION")

  let serviceInformations = map[
    ["name", serviceName],
    ["id", serviceId],
    ["version", serviceVersion],
    ["url", serviceBaseUrl+"/"+serviceName],
    ["operations", [
      map[
        ["name", "product"],
        ["url", serviceBaseUrl+"/"+serviceName+"/product"],
        ["usage", serviceBaseUrl+"/"+serviceName+"/product/:a/:b"],
        ["method", "GET"],
        ["args", map[["a","double"], ["b","double"]]],
        ["result", map[["result", "double"]]],
        ["description", "a great product service"]
      ],
      map[
        ["name", "divide"],
        ["url", serviceBaseUrl+"/"+serviceName+"/divide"],
        ["usage", serviceBaseUrl+"/"+serviceName+"/divide/:a/:b"],
        ["method", "GET"],
        ["args", map[["a","double"], ["b","double"]]],
        ["result", map[["result", "double"]]],
        ["description", "a great divide service"]
      ],
      map[
        ["name", "addition"],
        ["url", serviceBaseUrl+"/"+serviceName+"/addition"],
        ["usage", serviceBaseUrl+"/"+serviceName+"/addition/:a/:b"],
        ["method", "GET"],
        ["args", map[["a","double"], ["b","double"]]],
        ["result", map[["result", "double"]]],
        ["description", "a great addition service"]
      ],
      map[
        ["name", "concat"],
        ["url", serviceBaseUrl+"/"+serviceName+"/concat"],
        ["usage", serviceBaseUrl+"/"+serviceName+"/concat"],
        ["method", "POST"],
        ["args", map[["a","string"], ["b","string"]]],
        ["result", map[["result", "string"]]],
        ["description", "a great string concatenation service"]
      ]
    ]]
  ]

  # heartbeat
  let hb = poks.services.heartBeat(env, System.getenv(): get("SERVICE_CREDENTIALS"))

  hb: send(DynamicObject()
    : serverUrl(serverUrl)
    : data(
        serviceInformations
      )
    : refresh(3000_L)
    : stop(false)
  )

  # service
  setPort(port)

  # string concatenation
  post(serviceName+"/concat", |request, response| -> trying({

    let data = JSON.parse(request: body())

    let a = data: get("a")
    let b = data: get("b")

    return DynamicObject()
      : a(a)
      : b(b)
      : result(a: toString() + b: toString())
  })
  : either(
    |content| -> response: jsonPayLoad(content),
    |error| -> response: jsonPayLoad(DynamicObject(): message(error: message()))
  ))



  # http://localhost:9090/calculator/product/9/789
  get(serviceName+"/product/:a/:b", |request, response| -> trying({
    let a = Double.parseDouble(request: params(":a"))
    let b = Double.parseDouble(request: params(":b"))

    return DynamicObject()
      : a(a)
      : b(b)
      : result(a * b)
  })
  : either(
    |content| -> response: jsonPayLoad(content),
    |error| -> response: jsonPayLoad(DynamicObject(): message(error: message()))
  ))

  # http://localhost:9090/calculator/divide/9/789
  get(serviceName+"/divide/:a/:b", |request, response| -> trying({
    let a = Double.parseDouble(request: params(":a"))
    let b = Double.parseDouble(request: params(":b"))

    return DynamicObject()
      : a(a)
      : b(b)
      : result(a / b)
  })
  : either(
    |content| -> response: jsonPayLoad(content),
    |error| -> response: jsonPayLoad(DynamicObject(): message(error: message()))
  ))

  # http://localhost:9090/calculator/addition/9/789
  get(serviceName+"/addition/:a/:b", |request, response| -> trying({
    let a = Double.parseDouble(request: params(":a"))
    let b = Double.parseDouble(request: params(":b"))

    return DynamicObject()
      : a(a)
      : b(b)
      : result(a + b)
  })
  : either(
    |content| -> response: jsonPayLoad(content),
    |error| -> response: jsonPayLoad(DynamicObject(): message(error: message()))
  ))

  # http://localhost:9090/calculator/informations
  get(serviceName+"/informations", |request, response| -> trying({
    return serviceInformations
  })
  : either(
    |content| -> response: jsonPayLoad(content),
    |error| -> response: jsonPayLoad(DynamicObject(): message(error: message()))
  ))

  # http://localhost:9090/calculator/hello
  get(serviceName+"/hello", |request, response| -> trying({
    return "hi"
  })
  : either(
    |content| -> response: jsonPayLoad(DynamicObject(): message(content)),
    |error| -> response: jsonPayLoad(DynamicObject(): message(error: message()))
  ))

  println("🌍 poks service "+ serviceName +" is listening on " + port + "...")
}
