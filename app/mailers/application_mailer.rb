class ApplicationMailer < ActionMailer::Base

  layout "mailer"

  def feedback(user, message)
    @message = message

    name = user.name
    email = user.email

    mail({
      from: "#{name} <#{email}>",
      to: "Avand Amiri <avand@avandamiri.com>",
      subject: "Feedback on While"
    })
  end

end
