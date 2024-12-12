import requests
import json

def test_meditation_api():
    # API配置
    url = "https://api.openai-hk.com/v1/chat/completions"
    headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer hk-x5f91r1000036565f0e7f95bcecd71305ce968153f60db60"
    }

    # 测试数据
    data = {
        "max_tokens": 1200,
        "model": "gpt-3.5-turbo",
        "temperature": 0.8,
        "top_p": 1,
        "presence_penalty": 1,
        "messages": [
            {
                "role": "system",
                "content": "你是一位专业的冥想引导师，擅长根据用户的情绪状态提供个性化的冥想引导。"
            },
            {
                "role": "user",
                "content": "请为一位正在感到焦虑的用户生成一段2分钟的冥想引导文本。"
            }
        ]
    }

    try:
        print("正在发送请求...")
        response = requests.post(
            url, 
            headers=headers, 
            data=json.dumps(data).encode('utf-8')
        )
        
        print(f"\n状态码: {response.status_code}")
        print("\n完整响应:")
        print(json.dumps(response.json(), indent=2, ensure_ascii=False))
        
        if response.status_code == 200:
            result = response.json()
            meditation_text = result['choices'][0]['message']['content']
            print("\n生成的冥想文本:")
            print(meditation_text)
        else:
            print(f"\n请求失败: {response.text}")
            
    except Exception as e:
        print(f"发生错误: {e}")

if __name__ == "__main__":
    test_meditation_api() 