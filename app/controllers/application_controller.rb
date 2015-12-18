require 'net/http'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  skip_before_filter :verify_authenticity_token, only: [:registration, :quiz]


  def index
    render text: 'Pushkin'
  end

  def quiz
    question, id, level = params[:question], params[:id], params[:level]
    #q = Question.new body: question, level: level, rubyroid_id: id
    #q.save
    
    logger.info params
    answer = send "level#{level}", question
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

    answer = level2 question
    logger.info  answer
    render json: {answer: answer}
  end

  private

  

  def level1(question)
    poem = find_poem_by_full_string(question)
    title = poem.try(:title)
  end

  def level2(question)
    splited = question.partition '%WORD%'
    
    text = find_poem_with_replaced_word(splited).try :body
    find_replaced_word_in_poem text, splited
  end

  def level3(question)
    lines = question.split "\n"
    first_replaced_word = level2 lines[0]
    second_raplaced_word = level2 lines[1]
    "#{first_replaced_word},#{second_raplaced_word}"
  end

  def level4(question)
    lines = question.split "\n"
    first_replaced_word = level2 lines[0]
    second_raplaced_word = level2 lines[1]
    third_replaced_word = level2 lines[2]
    "#{first_replaced_word},#{second_raplaced_word},#{third_replaced_word}"
  end

  def find_poem_by_full_string(question)
    find_poem_with_replaced_word question.partition ''
  end

  def find_poem_with_replaced_word(splited)
    Poem.where('body ~* ?', splited[0] + '[А-Яа-я]*' + splited[2]).first
  end

  def find_replaced_word_in_poem(text, splited)
    if splited[0].empty?
      replaced_word = text.split(splited[2])[0].split(/\s|"|\(/)[-1] if text
    elsif splited[2].empty?
      replaced_word = text.split(splited[0])[1].split(/\s|,|\.|\?|!|:|;|\(|\)|"/)[0] if text
    else
      replaced_word = text.split(splited[0])[1].split(splited[2])[0] if text
    end
  end

  QUIZ_URI = URI("http://pushkin.rubyroid.by/quiz")

  def send_answer(answer, task_id)
    parameters = {
      answer: answer,
      token: Token.last.user_token,
      task_id: task_id
    }
    logger.info parameters
    Net::HTTP.post_form(QUIZ_URI, parameters)
  end
end
