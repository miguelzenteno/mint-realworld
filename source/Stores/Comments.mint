store Stores.Comments {
  state status : Api.Status(Array(Comment)) = Api.Status::Initial
  state postStatus : Api.Status(Comment) = Api.Status::Initial
  state slug : String = ""

  fun reset : Promise(Never, Void) {
    next { status = Api.Status::Initial }
  }

  fun post (comment : String) : Promise(Never, Void) {
    sequence {
      next { postStatus = Api.Status::Loading }

      params =
        encode { comment = { body = comment } }

      status =
        Http.post("/articles/" + slug + "/comments")
        |> Http.jsonBody(params)
        |> Api.send(
          (object : Object) : Result(Object.Error, Comment) => {
            Object.Decode.field(
              "comment",
              (input : Object) : Result(Object.Error, Comment) => { decode input as Comment },
              object)
          })

      next { postStatus = status }
    }
  }

  fun reload : Promise(Never, Void) {
    load(slug)
  }

  fun load (newSlug : String) : Promise(Never, Void) {
    sequence {
      next { status = Api.Status::Loading }

      status =
        Http.get("/articles/" + newSlug + "/comments")
        |> Api.send(
          (object : Object) : Result(Object.Error, Array(Comment)) => {
            Object.Decode.field(
              "comments",
              (input : Object) : Result(Object.Error, Array(Comment)) => { decode input as Array(Comment) },
              object)
          })

      next
        {
          status = status,
          slug = newSlug
        }
    }
  }
}
