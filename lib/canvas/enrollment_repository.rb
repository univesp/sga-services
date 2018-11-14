module Canvas
  require_relative '../../lib/canvas/repository'
  class EnrollmentRepository < Repository
    def create_enrollment(user_id,
                          role,
                          sis_id,
                          status,
                          limit_section_privileges,
                          enroll_type = 'course',
                          save_log = false)

      root_resource_name = 'courses'
      root_resource_sis_type = 'sis_course_id'
      if enroll_type == 'section'
        root_resource_name = 'sections'
        root_resource_sis_type = 'sis_section_id'
      end

      resources = [
        {
          name: root_resource_name,
          id: "#{root_resource_sis_type}:#{sis_id}"
        },
        { name: 'enrollments' }
      ]
      params = {
        'enrollment[user_id]'                            => user_id,
        'enrollment[type]'                               => role,
        'enrollment[enrollment_state]'                   => status,
        'enrollment[limit_privileges_to_course_section]' => limit_section_privileges
      }

      res_enrollment = set_by_resources(resources, :post, params)
      return res_enrollment unless save_log

      response_to_client = JSON.parse res_enrollment
      log_id = Logs::GcloudLogger.log_response(response_to_client, @env).id
      JSON.parse(response_to_client)
          .merge({ log_id: log_id })
          .to_json
    end

    def create_student_enrollment(academic_register, sis_section_id)
      user_by_sis_id = @user_repository.read_user_by_sis_id academic_register,
                                                            nil
      res_user = JSON.parse user_by_sis_id
      if res_user['service_status'] == 'ok'
        res_enrollment = JSON.parse(
          create_enrollment(res_user['canvas_response']['id'],
                            'StudentEnrollment',
                            sis_section_id,
                            'active',
                            true)
        )
        if res_enrollment.key? 'errors'
          response_to_client = {
            service_status: :error,
            service_errors: ['Erro ao matricular o aluno'],
            canvas_response: res_enrollment
          }
        else
          response_to_client = {
            service_status: :ok,
            canvas_response: res_enrollment
          }
        end
      else
        response_to_client = res_user
      end

      log_id = Logs::GcloudLogger.log_response(response_to_client, @env).id
      JSON.parse(response_to_client)
          .merge({ log_id: log_id })
          .to_json
    end

    def read_user_enrollments(sis_user_id)
      res = JSON.parse(
        get_by_resources([
          { name: 'users', id: "sis_user_id:#{sis_user_id}" },
          { name: 'enrollments' }
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

    def delete_user_enrollment(sis_user_id,
                               sis_section_id = nil,
                               task = 'inactivate')
      final_service_status = :ok
      canvas_response = []

      res_enrollments = JSON.parse get_by_resources([
                                    { name: 'users', id: "sis_user_id:#{sis_user_id}" },
                                    { name: 'enrollments' }
                                   ])
      res_enrollments.each do |enroll|
        course_id = enroll['course_id']
        enroll_id = enroll['id']
        next if sis_section_id && sis_section_id != enroll['sis_section_id']

        resources = [
          { name: 'courses', id: course_id.to_s },
          { name: 'enrollments', id: enroll_id.to_s }
        ]

        response_to_client = JSON.parse set_by_resources resources,
                                                         :delete,
                                                         { 'task' => task }
        if response_to_client['errors']
          final_service_status = :error
        end
        log_id = Logs::GcloudLogger.log_response(response_to_client, @env).id
        canvas_response <<  JSON.parse(response_to_client)
                                .merge({ log_id: log_id })
                                .to_json
      end

      {
        service_status: final_service_status,
        canvas_response: canvas_response
      }.to_json
    end
  end
end