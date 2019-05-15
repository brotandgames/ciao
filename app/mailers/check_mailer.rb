class CheckMailer < ApplicationMailer
  def change_status_mail
  	@name = params[:name]
  	@status_before = params[:status_before]
  	@status_after = params[:status_after]
    mail(subject: "[ciao] #{@name}: Status changed (#{@status_after})")
  end
end
