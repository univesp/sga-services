module Canvas
  require_relative '../../lib/canvas/repository'
  require_relative '../logs/gcloud_logger'
  class UserRepository < Repository
    def create_user(name, sis_user_id)
      resources = [
        { name: 'users' }
      ]
      params = {
        'user[name]'              => name,
        'user[short_name]'        => name,
        'pseudonym[unique_id]'    => sis_user_id,
        'pseudonym[sis_user_id]'  => sis_user_id
      }

      response_to_client = JSON.parse set_by_resources resources,
                                                       :post,
                                                       params,
                                                       '/accounts/1'
      log_id = Logs::GcloudLogger.log_response(response_to_client, @env).id
      JSON.parse(response_to_client)
          .merge({ log_id: log_id })
          .to_json
    end

    def read_user_by_sis_id(sis_id, no_sis)
      resource_id = ''
      resource_id += 'sis_user_id:' unless no_sis # uses sis by default
      resource_id += "#{sis_id}"

      res = JSON.parse(
        get_by_resources([
          { name: 'users', id: resource_id },
          { name: 'profile' }
        ])
      )

      if res['id']
        response_to_client = {
          service_status: :ok,
          canvas_response: res
        }
      else
        response_to_client = {
          service_status: :error,
          service_errors: ['Usuário inexistente'],
          canvas_response: res
        }
      end

      response_to_client.to_json
    end

    def read_user_profile(sis_user_id)
      res = JSON.parse(
        get_by_resources([
          { name: 'users', id: "sis_user_id:#{sis_user_id}" },
          { name: 'profile' }
        ])
      )

      if res.is_a?(Hash) && res.has_key?('errors')
        response_to_client = {
          service_status: :error,
          service_errors: ['Usuário inexistente'],
          canvas_response: res
        }
      else
        response_to_client = {
          service_status: :ok,
          canvas_response: res
        }
      end

      response_to_client.to_json
    end

    def delete_user(sis_user_id)
      resources = [
        { name: 'users', id: "sis_user_id:#{sis_user_id}" }
      ]

      response_to_client = JSON.parse set_by_resources resources,
                                                       :delete,
                                                       '/accounts/1'
      log_id = Logs::GcloudLogger.log_response(response_to_client, @env).id
      JSON.parse(response_to_client)
          .merge({ log_id: log_id })
          .to_json
    end
  end
end