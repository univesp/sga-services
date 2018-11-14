module Canvas
  require_relative '../../lib/canvas/repository'
  class CourseRepository < Repository
    def create_course(name, code, date_begin)
      resources = [
        { name: 'courses' }
      ]
      name_parts = name.split('-')
      name_without_code = name_parts[0..name_parts.size-2].join('-')
      # "parts.size-2" in the case of the name already to have a hyphen
      params = {
        'course[allow_student_discussion_editing]'      => true,
        'course[allow_student_discussion_topics]'       => false,
        'course[allow_student_forum_attachments]'       => true,
        'course[allow_student_organized_groups]'        => false,
        'course[apply_assignment_group_weights]'        => false,
        'course[course_code]'                           => name_without_code,
        'course[course_format]'                         => 'online',
        'course[hide_final_grades]'                     => true,
        'course[is_public]'                             => true,
        'course[license]'                               => 'private',
        'course[lock_all_announcements]'                => true,
        'course[name]'                                  => name,
        'course[open_enrollment]'                       => false,
        'course[public_syllabus]'                       => false,
        'course[restrict_enrollments_to_course_dates]'  => false,
        'course[restrict_student_past_view]'            => false,
        'course[restrict_student_future_view]'          => false,
        'course[self_enrollment]'                       => false,
        'course[sis_course_id]'                         => code,
        'course[start_at]'                              => date_begin,
        'course[storage_quota_mb]'                      => 5000,
        'enroll_me'                                     => false,
        'enable_sis_reactivation'                       => true,
        'offer'                                         => false
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

    def create_course_section(name, code, course_id)
      resources = [
        { name: 'courses', id: course_id },
        { name: 'sections' }
      ]
      params = {
        'course_section[name]'            => name,
        'course_section[sis_section_id]'  => code
      }

      response_to_client = JSON.parse set_by_resources(resources, :post, params)
      log_id = Logs::GcloudLogger.log_response(response_to_client, @env).id
      JSON.parse(response_to_client)
          .merge({ log_id: log_id })
          .to_json
    end

    def read_course_from_sis(course_id)
      res = JSON.parse(
        get_by_resources([
          { name: 'courses', id: "sis_course_id:#{course_id}" }
        ],
        '/accounts/1')
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

    def read_sections_from_course(course_id)
      res = JSON.parse(
        get_by_resources([
          { name: 'courses', id: course_id },
          { name: 'sections' }
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
  end
end