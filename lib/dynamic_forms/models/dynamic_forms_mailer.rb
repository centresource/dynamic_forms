module DynamicForms
  module Models
    module DynamicFormsMailer

      def self.included(model)
        model.send(:include, InstanceMethods)

        model.class_eval do
          helper "dynamic_forms::form_submissions"
        end
      end

      module InstanceMethods
        def form_submission(form_submission)
          @subject         = I18n.t(:form_submission_subject, 
                                    :scope => [:dynamic_forms, :models, :dynamic_forms_mailer], 
                                    :name => form_submission.form.name)
          @recipients      = form_submission.form.email
          @from            = DynamicForms.configuration.mailer_sender
          @sent_on         = Time.now
          @body            = {:form_submission => form_submission}
          @form_submission = form_submission

          form_submission.each_field do |field, value|
            if field.is_a?(::FormField::FileField) && !value.blank? && file = File.read(File.join(Rails.root, 'public', value))
              attachments[value.split('/').last.to_s] = file
            end
          end

          mail(to: @recipients,
               from: @from,
               subject: @subject,
               content_type: "text/html",
               body: render('form_submission'))
        end
      end
    end
  end
end
