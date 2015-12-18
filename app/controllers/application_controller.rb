class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def index
    render text: 'Pushkin'
  end

  

  def registration
    token, question = params[:token], params[:question]
    Token.create user_token: token

    answer = level2 question
    render json: {answer: answer}
  end

  private

  def level2(question)
    splited = question.partition '%WORD%'
    text = Poem.where('body ~* ?', splited[0] + '[А-Яа-я]*' + splited[2]).first.body
    if splited[0].empty?
      replaced_word = text.split(splited[2])[0].split(/\s|"|\(/)[-1]
    elsif splited[2].empty?
      replaced_word = text.split(splited[0])[1].split(/\s|,|\.|\?|!|:|;|\(|\)|"/)[0]
    else
      replaced_word = text.split(splited[0])[1].split(splited[2])[0]
    end

    replaced_word
  end
end
