const axios = require('axios');
require('dotenv').config();

const processImageWithOpenAI = async (imageBuffer) => {
    // Tạo FormData để gửi ảnh
    const formData = new FormData();
    formData.append('image', new Blob([imageBuffer]), 'image.jpg');

    try {
        const response = await axios.post('https://api.openai.com/v1/images/analyze', formData, {
            headers: {
                'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`,
                'Content-Type': 'multipart/form-data',
            },
            params: {
                model: 'gpt-4-vision-preview',
                prompt: `Extract the following information from the receipt image in JSON format with UTF-8:
                - amount (number): Total amount of the receipt.
                - description (string): A brief description of the transaction.
                - date (string, format: YYYY-MM-DD): Transaction date on the receipt.
                if not found field you can return null or ''
                `,
                max_tokens: 300,
            }
        });

        // Trả về dữ liệu từ OpenAI
        return response.data.choices[0].message.content;
    } catch (error) {
        console.error('Error calling OpenAI API:', error);
        throw new Error('Failed to process image with OpenAI');
    }
};

module.exports = {
  processImageWithOpenAI,
};