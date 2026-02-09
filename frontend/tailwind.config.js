/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{vue,js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        lightBlue: '#E9F1FA',
        brightBlue: '#00ABE4',
        white: '#FFFFFF',
      },
      boxShadow: {
        panel: '0 14px 40px rgba(0, 78, 120, 0.12)',
      },
    },
  },
  plugins: [],
}
