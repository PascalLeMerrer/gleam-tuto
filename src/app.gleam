import app/router
import app/web.{Context}
import gleam/result

import dot_env
import dot_env/env
import gleam/erlang/process
import mist
import wisp
import wisp/wisp_mist

pub fn main() {
  wisp.configure_logger()

  dot_env.new()
  |> dot_env.set_path(".env")
  |> dot_env.set_debug(False)
  |> dot_env.load

  let assert Ok(secret_key_base) = env.get_string("SECRET_KEY_BASE")

  let ctx =
    Context(
      static_directory: wisp.priv_directory("app")
        |> result.unwrap("priv/static"),
      items: [],
    )

  let handler = router.handle_request(_, ctx)
  let assert Ok(_) =
    wisp_mist.handler(handler, secret_key_base)
    |> mist.new
    |> mist.port(4000)
    |> mist.start_http

  process.sleep_forever()
}