module Canvas
  require_relative '../../lib/canvas/repository'
  class GroupRepository < Repository
    def create_group(category_id, name)
      resources = [
        { name: 'group_categories', id: category_id },
        { name: 'groups' }
      ]
      params = {
        'name'        => name,
        'join_level'  => 'invitation_only'
      }

      response_to_client = JSON.parse set_by_resources resources,
                                                       :post,
                                                       params
      log_id = Logs::GcloudLogger.log_response(response_to_client, @env).id
      JSON.parse(response_to_client)
          .merge({ log_id: log_id })
          .to_json
    end

    def create_group_category(course_id)
      resources = [
        { name: 'courses', id: course_id },
        { name: 'group_categories' }
      ]
      params = {
        'name' => 'Grupos'
      }

      response_to_client = JSON.parse set_by_resources resources,
                                                       :post,
                                                       params
      log_id = Logs::GcloudLogger.log_response(response_to_client, @env).id
      JSON.parse(response_to_client)
          .merge({ log_id: log_id })
          .to_json
    end

    def create_group_membership(group_id, user_id)
      resources = [
        { name: 'groups', id: group_id },
        { name: 'memberships' }
      ]
      params = {
        'user_id' => "sis_user_id:#{user_id}"
      }

      response_to_client = JSON.parse set_by_resources resources,
                                                       :post,
                                                       params
      log_id = Logs::GcloudLogger.log_response(response_to_client, @env).id
      JSON.parse(response_to_client)
          .merge({ log_id: log_id })
          .to_json
    end

    def read_group_categories(course_id)
      res = JSON.parse(
        get_by_resources([
          { name: 'courses', id: course_id },
          { name: 'group_categories' }
        ])
      )

      if res.is_a?(Hash) && res.has_key?('errors')
        response_to_client = {
          service_status: :error,
          service_errors: ['Grupo de categorias inexistente'],
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

    def read_groups_from_course(course_id)
      res = JSON.parse(
        get_by_resources([
          { name: 'courses', id: course_id },
          { name: 'groups' }
        ])
      )

      if res.is_a?(Hash) && res.has_key?('errors')
        response_to_client = {
          service_status: :error,
          service_errors: ['Curso inexistente'],
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

    def delete_group_membership(group_id, user_id)
      resources = [
        { name: 'groups', id: group_id },
        { name: 'users', id: "sis_user_id:#{user_id}" }
      ]

      response_to_client = JSON.parse set_by_resources resources,
                                                       :delete
      log_id = Logs::GcloudLogger.log_response(response_to_client, @env).id
      JSON.parse(response_to_client)
          .merge({ log_id: log_id })
          .to_json
    end
  end
end