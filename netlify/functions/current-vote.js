import { supabase } from '../../utils/supabase'

exports.handler = async (event) => {
  try {
    // 获取当前活跃投票
    const { data: vote, error: voteError } = await supabase
      .from('votes')
      .select('*')
      .eq('is_active', true)
      .single()
    
    if (voteError) throw voteError
    if (!vote) {
      return {
        statusCode: 404,
        body: JSON.stringify({ error: '没有活跃的投票' })
      }
    }
    
    // 获取投票选项
    const { data: options, error: optionsError } = await supabase
      .from('vote_options')
      .select('*')
      .eq('vote_id', vote.id)
    
    if (optionsError) throw optionsError
    
    // 获取每个选项的票数
    const optionsWithVotes = await Promise.all(options.map(async (option) => {
      const { count, error: voteCountError } = await supabase
        .from('user_votes')
        .select('*', { count: 'exact' })
        .eq('option_id', option.id)
      
      if (voteCountError) throw voteCountError
      
      return {
        ...option,
        votes: count
      }
    }))
    
    return {
      statusCode: 200,
      body: JSON.stringify({
        ...vote,
        options: optionsWithVotes
      })
    }
  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({ error: error.message })
    }
  }
}