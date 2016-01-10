require 'net/http'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  skip_before_filter :verify_authenticity_token, only: [:registration, :quiz]
  

  def index
    loop do
    end
    #render text: 'Pushkin'
  end

  def quiz
    question = params[:question]
    id = params[:id]
    level = params[:level]
    
    @@generator ||= AnswerGenerator.new
    answer = @@generator.send "level#{level}", question

    logger.info answer

    send_answer answer, id
    render nothing: true
  end

  def registration
    token = params[:token]
    logger.info params[:question]
    question = params[:question]

    logger.info params
    @token = Token.new(user_token: token)
    logger.info "TOKEN CREATED"
    if @token.save!
      logger.info "TOKEN SAVED"
    end

    answer = level2 [question]
    logger.info  answer
    render json: {answer: answer}
  end

  private

  QUIZ_URI = URI("http://pushkin.rubyroid.by/quiz")

  def send_answer(answer, task_id)
    $token ||= Token.last.user_token
    parameters = {
      answer: answer,
      token: $token,
      task_id: task_id
    }

    $session ||= Patron::Session.new({base_url: 'http://pushkin.rubyroid.by', headers: {"Keep-Alive" => "timeout=2, max=1000"}, timeout: 2})

    response = $session.post('/quiz', parameters)
    logger.info "RESPONCE: #{response.body}"
  end
end
