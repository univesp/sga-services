module Canvas
  require_relative '../../lib/canvas/repository'
  class AssignmentRepository < Repository
    def read_all_submissions_of_assignment(course_id, assignment_id)
      res = JSON.parse(
        get_by_resources([
          { name: 'courses', id: course_id },
          { name: 'assignments', id: assignment_id },
          { name: 'submissions' }
        ])
      )

      if res.is_a?(Hash) && res.has_key?('errors')
        response_to_client = {
          service_status: :error,
          service_errors: ['Curso e/ou tarefa inexistentes'],
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

    def read_assignment_by_course_and_name(course_id, assign_name)
      res = JSON.parse(
        get_by_resources([
          { name: 'courses', id: course_id },
          { name: 'assignments' }],
          '',
          assign_name
        )
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

    def read_submission_by_id(course_id, assignment_id, submission_id)
      res = JSON.parse(
        get_by_resources([
          { name: 'courses', id: course_id },
          { name: 'assignments', id: assignment_id },
          { name: 'submissions', id: submission_id }
        ])
      )

      if res.is_a?(Hash) && res.has_key?('errors')
        response_to_client = {
          service_status: :error,
          service_errors: ['Submissão inexistente'],
          canvas_response: res
        }.
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