class ApplicationMailer < ActionMailer::Base

  layout "mailer"

  def feedback(user, message)
    @message = message

    name = user.try(:name) || "While Guest"
    email = user.try(:email) || "guest@whilelist.com"

    mail({
      from: "#{name} <#{user.try(:email) || ""}>",
      to: "Avand Amiri <avand@avandamiri.com>",
      subject: "Feedback on While"
    })
  end

end
