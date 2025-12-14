class QuizChannel < ApplicationCable::Channel
  def subscribed
    @quiz = Quiz.find(params[:quiz_id])
    @user = current_user
    @quiz_id = @quiz.id
    
    stream_from "quiz_#{@quiz.id}"
    
    participants = Rails.cache.read("quiz_#{@quiz.id}_participants") || []
    participants << { 
      id: @user.id, 
      nickname: @user.nickname, 
      is_author: @quiz.author_id == @user.id 
    }
    Rails.cache.write("quiz_#{@quiz.id}_participants", participants.uniq { |p| p[:id] })
    
    broadcast_state_update
  end
  
  def unsubscribed
    participants = Rails.cache.read("quiz_#{@quiz.id}_participants") || []
    participants.reject! { |p| p[:id] == @user.id }
    Rails.cache.write("quiz_#{@quiz.id}_participants", participants)
    
    broadcast_state_update
  end
  
  def start_quiz(data)
    unless @quiz.author_id == @user.id
      return
    end
        
    Rails.cache.write("quiz_#{@quiz.id}_status", 'started')
    Rails.cache.write("quiz_#{@quiz.id}_current_question", 0)
    Rails.cache.write("quiz_#{@quiz.id}_paused", false)
    
    # ===== ВСЕ ВОПРОСЫ ЗАГРУЖАЮТСЯ ОДИН РАЗ =====
    puts "📥 Загружаем все вопросы для квиза #{@quiz.id}..."
    
    # Загружаем вопросы с ответами ОДИН РАЗ
    questions_data = @quiz.questions.includes(:answers).order(:order_index).map do |question|
      {
        id: question.id,
        text: question.text,
        reward: question.reward,
        time_limit: question.time_limit,
        order_index: question.order_index,
        # Сохраняем информацию о правильности для сервера
        server_answers: question.answers.map { |answer| 
          { 
            id: answer.id, 
            answer_text: answer.answer_text,
            is_correct: answer.is_correct
          } 
        },
        # Для клиентов - только id и текст
        client_answers: question.answers.shuffle.map { |answer| 
          { 
            id: answer.id, 
            answer_text: answer.answer_text
          } 
        }
      }
    end
    
    puts "✅ Загружено #{questions_data.count} вопросов"
    
    # Сохраняем в кеше
    Rails.cache.write("quiz_#{@quiz.id}_questions", questions_data)
    Rails.cache.write("quiz_#{@quiz.id}_total_questions", questions_data.count)
    
    # Подготовка данных для отправки клиентам
    questions_for_clients = questions_data.map do |question|
      {
        id: question[:id],
        text: question[:text],
        reward: question[:reward],
        time_limit: question[:time_limit],
        order_index: question[:order_index],
        answers: question[:client_answers]
      }
    end

    broadcast_to_all({
      action: 'quiz_started',
      message: "Quiz is starting",
      started_by: @user.nickname,
      questions: questions_for_clients,
      total_questions: questions_data.count
    })
  end
  
  def next_question(data)
    return unless @quiz.author_id == @user.id
    
    # Получаем текущий вопрос из кеша
    current = Rails.cache.read("quiz_#{@quiz.id}_current_question").to_i
    next_q = current + 1
    
    # Получаем все вопросы из кеша
    questions = Rails.cache.read("quiz_#{@quiz.id}_questions") || []
    total_questions = questions.count
    
    if next_q <= total_questions  # ← НЕТ ЗАПРОСА К БД!
      # Обновляем текущий вопрос в кеше
      Rails.cache.write("quiz_#{@quiz.id}_current_question", next_q)
      
      # Берем следующий вопрос из кешированных данных
      question_data = questions[current]  # ← НЕТ ЗАПРОСА К БД!
      
      # Готовим данные для клиентов
      question_for_client = {
        id: question_data[:id],
        text: question_data[:text],
        reward: question_data[:reward],
        time_limit: question_data[:time_limit],
        answers: question_data[:client_answers].shuffle  # перемешиваем каждый раз
      }
      
      broadcast_to_all({
        action: 'next_question',
        question: question_for_client,
        question_number: next_q,
        total_questions: total_questions  # ← НЕТ ЗАПРОСА К БД!
      })
    else
      end_quiz(data)
    end
  end
  
  def pause_quiz(data)
    return unless @quiz.author_id == @user.id
    
    paused = data['paused']
    Rails.cache.write("quiz_#{@quiz.id}_paused", paused)
    
    broadcast_to_all({ action: paused ? 'quiz_paused' : 'quiz_resumed' })
  end
  
  def submit_answer(data)
    answers = Rails.cache.read("quiz_#{@quiz.id}_answers") || {}
    answers[@user.id] ||= {}
    answers[@user.id][data['question_id']] = {
      answer_id: data['answer_id'],
      timestamp: Time.current.to_i
    }
    Rails.cache.write("quiz_#{@quiz.id}_answers", answers)
  end
  
  def end_quiz(data)
    participants = Rails.cache.read("quiz_#{@quiz.id}_participants") || []
    answers = Rails.cache.read("quiz_#{@quiz.id}_answers") || {}
    questions = Rails.cache.read("quiz_#{@quiz.id}_questions") || []
    
    statistics = participants.map do |p|
      user_answers = answers[p[:id]] || {}
      correct_count = 0
      
      user_answers.each do |question_id, answer_data|
        # Находим вопрос в кешированных данных
        question = questions.find { |q| q[:id] == question_id }
        if question
          # Находим ответ в server_answers (там есть is_correct)
          answer = question[:server_answers].find { |a| a[:id] == answer_data[:answer_id] }
          if answer && answer[:is_correct]
            correct_count += 1
          end
        end
      end
      
      {
        user_id: p[:id],
        nickname: p[:nickname],
        correct_answers: correct_count,
        total_questions: questions.count  # ← НЕТ ЗАПРОСА К БД!
      }
    end
    
    broadcast_to_all({
      action: 'quiz_ended',
      statistics: statistics
    })
    
    # Очищаем кеш (опционально)
    Rails.cache.delete("quiz_#{@quiz.id}_questions")
    Rails.cache.delete("quiz_#{@quiz.id}_answers")
    Rails.cache.delete("quiz_#{@quiz.id}_status")
    Rails.cache.delete("quiz_#{@quiz.id}_current_question")
    Rails.cache.delete("quiz_#{@quiz.id}_paused")
  end
  
  private
  
  def broadcast_to_all(data)
    ActionCable.server.broadcast("quiz_#{@quiz_id}", data)
  end
  
  def broadcast_state_update
    participants = Rails.cache.read("quiz_#{@quiz.id}_participants") || []
    status = Rails.cache.read("quiz_#{@quiz.id}_status")
    current_question = Rails.cache.read("quiz_#{@quiz.id}_current_question").to_i
    paused = Rails.cache.read("quiz_#{@quiz.id}_paused")
    total_questions = Rails.cache.read("quiz_#{@quiz.id}_total_questions") || 0
    
    broadcast_to_all({
      action: 'state_update',
      participants: participants,
      status: status,
      current_question: current_question,
      paused: paused,
      total_questions: total_questions
    })
  end
end