module Logs
  class GcloudLogger
    def self.log_response(response, env)
      begin
        project_id = ENV['DATASTORE_PROJECT_ID']
        dataset = Google::Cloud::Datastore.new project: project_id,
                                               keyfile: ENV['DATASTORE_KEYFILE']
        kind = ENV['DATASTORE_TYPE']
        task_key = dataset.key kind
        task = dataset.entity task_key do |t|
          t['action'] = "#{env['REQUEST_METHOD']} #{env['REQUEST_PATH']}"
          t['date'] = Time.now.to_s
          t['ip'] = env['REMOTE_ADDR']
          t['requester'] = env['HTTP_AUTHORIZATION'].split(':')[0]
          t['response'] = response.to_s
          t['service'] = 'Canvas'
          t['userAgent'] = env['HTTP_USER_AGENT']
        end
        dataset.save task
        JSON.parse(
          {
            id: task.key.id.to_s,
            status: :ok,
          }.to_json,
          object_class: OpenStruct
        )
      rescue => e
        JSON.parse(
          {
            id: nil,
            status: :exception,
            message: e.message
          }.to_json,
          object_class: OpenStruct
        )
      end
    end
  end
end