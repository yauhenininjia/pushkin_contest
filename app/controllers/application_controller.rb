class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  skip_before_filter :verify_authenticity_token, only: [:registration]

  def index
    render text: 'Pushkin'
  end

  def quiz
    question, id, level = params[:question], params[:id], params[:level]

    answer = send "level#{level}", question
    send_answer answer, id
    render nothing: true
  end

  def registration
    token, question = params[:token], params[:question]
    p "PARAMS", params
    logger.info "PARAMS", params

    @token = Token.new(user_token: token)
    if @token.save!
      p "TOKEN SAVED"
      logger.info "TOKEN SAVED"
    end

    answer = level2 question
    logger.info  answer
    render json: {answer: answer}
  end

  private

  QUIZ_URI = URI("http://pushkin.rubyroid.by/quiz")

  def level1(question)
    title = find_poem_by_string(question).title
  end

  def level2(question)
    splited = question.partition '%WORD%'

    text = find_poem_by_string(splited).body
    find_replaced_word_in_poem text, splited
  end

  def find_poem_by_string(splited)
    Poem.where('body ~* ?', splited[0] + '[А-Яа-я]*' + splited[2]).first
  end

  def find_replaced_word_in_poem(text, splited)
    if splited[0].empty?
      replaced_word = text.split(splited[2])[0].split(/\s|"|\(/)[-1]
    elsif splited[2].empty?
      replaced_word = text.split(splited[0])[1].split(/\s|,|\.|\?|!|:|;|\(|\)|"/)[0]
    else
      replaced_word = text.split(splited[0])[1].split(splited[2])[0]
    end
  end

  def send_answer(answer, task_id)
    parameters = {
      answer: answer,
      token: Token.last,
      task_id: task_id
    }
    Net::HTTP.post_form(QUIZ_URI, parameters)
  end
end
