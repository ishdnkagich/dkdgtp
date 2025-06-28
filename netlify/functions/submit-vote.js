import { supabase } from '../../utils/supabase'

exports.handler = async (event) => {
  const { userId, voteId, optionId } = JSON.parse(event.body)
  
  try {
    // 检查用户是否已经投过票
    const { count, error: voteCheckError } = await supabase
      .from('user_votes')
      .select('*', { count: 'exact' })
      .eq('user_id', userId)
      .eq('vote_id', voteId)
    
    if (voteCheckError) throw voteCheckError
    if (count > 0) {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: '您已经投过票了' })
      }
    }
    
    // 插入投票记录
    const { error } = await supabase
      .from('user_votes')
      .insert({
        user_id: userId,
        vote_id: voteId,
        option_id: optionId
      })
    
    if (error) throw error
    
    return {
      statusCode: 200,
      body: JSON.stringify({ success: true })
    }
  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({ error: error.message })
    }
  }
}