import { supabase } from '../../utils/supabase'

exports.handler = async (event) => {
  const { username, email, password } = JSON.parse(event.body)
  
  try {
    // 注册新用户
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          username,
          role: 'user'
        }
      }
    })
    
    if (error) throw error
    
    return {
      statusCode: 200,
      body: JSON.stringify({
        id: data.user.id,
        email: data.user.email,
        role: 'user'
      })
    }
  } catch (error) {
    return {
      statusCode: 400,
      body: JSON.stringify({ error: error.message })
    }
  }
}