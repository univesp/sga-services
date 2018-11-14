module Canvas
  module Routes
    require_relative '../../lib/canvas/assignment_repository'
    require_relative '../../lib/canvas/course_repository'
    require_relative '../../lib/canvas/enrollment_repository'
    require_relative '../../lib/canvas/group_repository'
    require_relative '../../lib/canvas/user_repository'

    def self.included(base)
      base.before do
        @assignment_repository ||= AssignmentRepository.new @env
        @course_repository ||= CourseRepository.new @env
        @enrollment_repository ||= EnrollmentRepository.new @env
        @group_repository ||= GroupRepository.new @env
        @user_repository ||= UserRepository.new @env
      end

      # === Users
      base.post '/canvas/create_user' do
        @user_repository.create_user(
          params[:name],
          params[:sis_user_id]
        )
      end

      base.get '/canvas/read_user_by_sis_id' do
        @user_repository.read_user_by_sis_id(
          params[:sis_id],
          params[:no_sis]
        )
      end

      base.get '/canvas/read_user_profile' do
        @user_repository.read_user_profile(
          params[:sis_user_id]
        )
      end

      base.delete '/canvas/delete_user' do
        @user_repository.delete_user(
          params[:sis_user_id]
        )
      end

      # === Courses
      base.post '/canvas/create_course' do
        @course_repository.create_course(
          params[:name],
          params[:code],
          params[:date_begin]
        )
      end

      base.post '/canvas/create_course_section' do
        @course_repository.create_course_section(
          params[:name],
          params[:code],
          params[:course_id]
        )
      end

      base.get '/canvas/read_course_from_sis' do
        @course_repository.read_course_from_sis(
          params[:course_id]
        )
      end

      base.get '/canvas/read_sections_from_course' do
        @course_repository.read_sections_from_course(
          params[:course_id]
        )
      end

      # === Enrollments
      base.post '/canvas/create_enrollment' do
        save_log = true
        @enrollment_repository.create_enrollment(
          params[:user_id],
          params[:role],
          params[:sis_section_id],
          params[:status],
          params[:limit_section_privileges],
          params[:enroll_type],
          save_log
        )
      end

      base.post '/canvas/create_student_enrollment' do
        @enrollment_repository.create_student_enrollment(
          params[:academic_register],
          params[:sis_section_id]
        )
      end

      base.get '/canvas/read_user_enrollments' do
        @enrollment_repository.read_user_enrollments(
          params[:sis_user_id]
        )
      end

      base.delete '/canvas/delete_user_enrollment' do
        @enrollment_repository.delete_user_enrollment(
          params[:sis_user_id],
          params[:sis_section_id],
          params[:task]
        )
      end

      base.delete '/canvas/delete_all_user_enrollments' do
        @enrollment_repository.delete_user_enrollment(params[:sis_user_id])
      end

      # === Assignments
      base.get '/canvas/read_assignment_by_course_and_name' do
        @assignment_repository.read_assignment_by_course_and_name(
          params[:course_id],
          params[:assign_name]
        )
      end

      base.get '/canvas/read_all_submissions_of_assignment' do
        @assignment_repository.read_all_submissions_of_assignment(
          params[:course_id],
          params[:assignment_id]
        )
      end

      base.get '/canvas/read_submission_by_id' do
        @assignment_repository.read_submission_by_id(
          params[:course_id],
          params[:assignment_id],
          params[:submission_id]
        )
      end

      # === Groups
      base.post '/canvas/create_group' do
        @group_repository.create_group(
          params[:category_id],
          params[:name]
        )
      end

      base.post '/canvas/create_group_category' do
        @group_repository.create_group_category params[:course_id]
      end

      base.post '/canvas/create_group_membership' do
        @group_repository.create_group_membership(
          params[:group_id],
          params[:user_id]
        )
      end

      base.get '/canvas/read_group_categories' do
        @group_repository.read_group_categories params[:course_id]
      end

      base.get '/canvas/read_groups_from_course' do
        @group_repository.read_groups_from_course params[:course_id]
      end

      base.delete '/canvas/delete_group_membership' do
        @group_repository.delete_group_membership(
          params[:group_id],
          params[:user_id]
        )
      end
    end
  end
end