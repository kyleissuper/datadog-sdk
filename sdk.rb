{
  title: "Datadog",
  connection: {
    fields: [
      { 
        name: "api_key",
        control_type: "password",
        hint: "Get your keys here: https://app.datadoghq.com/account/settings#api",
        optional: false
      },
      {
        name: "application_key",
        control_type: "password",
        hint: "Required only when using `read` actions"
      }
    ],
    authorization: {
      type: "custom_auth",
      apply: lambda do |connection|
        params(connection)
      end
    },
    base_uri: lambda do |_connection|
      "https://api.datadoghq.com"
    end
  },
  test: lambda do |connection|
    if connection["application_key"].present?
      get("/api/v1/hosts").params(
        api_key: connection["api_key"],
        application_key: connection["application_key"]).
      after_error_response(403) do
        error("Could not authenticate. Please check your credentials.")
      end
    else
      get("/api/v1/validate").params(
        api_key: connection["api_key"]).
      after_error_response(403) do
        error("Could not authenticate. Please check your credentials.")
      end
    end
  end,
  webhook_keys: lambda do |_params, headers, _payload|
    headers["Workato-Key"]
  end,
  triggers: {
    new_event: {
      input_fields: lambda do |object_definitions|
        [
          { name: "Workato-Key" }
        ]
      end,
      webhook_key: lambda do |_connection, input|
        input["Workato-Key"]
      end,
      webhook_notification: lambda do |_connection, payload|
        payload
      end,
      dedup: lambda do |messages|
        messages["id"]
      end,
      output_fields: lambda do |object_definitions|
        object_definitions["webhook_event"]
      end,
    }
  },
  object_definitions: {
    webhook_event: {
      fields: lambda do
        [
          {
            "control_type": "text",
            "label": "ID",
            "type": "string",
            "name": "id"
          },
          {
            "control_type": "text",
            "label": "Title",
            "type": "string",
            "name": "title"
          },
          {
            "control_type": "text",
            "label": "Date",
            "type": "string",
            "name": "date"
          },
          {
            "control_type": "text",
            "label": "Last updated",
            "type": "string",
            "name": "last_updated"
          },
          {
            "control_type": "text",
            "label": "Event type",
            "type": "string",
            "name": "event_type"
          },
          {
            "control_type": "text",
            "label": "Body",
            "type": "string",
            "name": "body"
          },
          {
            "properties": [
              {
                "control_type": "text",
                "label": "ID",
                "type": "string",
                "name": "id"
              },
              {
                "control_type": "text",
                "label": "Name",
                "type": "string",
                "name": "name"
              }
            ],
            "label": "Org",
            "type": "object",
            "name": "org"
          }
        ]
      end
    }
  }
}
