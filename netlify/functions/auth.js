import { supabase } from '../../utils/supabase'

exports.handler = async (event) => {
  const { email, password } = JSON.parse(event.body)
  
  try {
    // 登录用户
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password
    })
    
    if (error) throw error
    
    // 获取用户角色
    const role = data.user.user_metadata?.role || 'user'
    
    return {
      statusCode: 200,
      body: JSON.stringify({
        id: data.user.id,
        email: data.user.email,
        role: role
      })
    }
  } catch (error) {
    return {
      statusCode: 401,
      body: JSON.stringify({ error: error.message })
    }
  }
}