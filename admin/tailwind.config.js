/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        cyberCyan: '#00E5FF',
        pulseRed: '#FF1744',
        safeGreen: '#00E676',
        warningAmber: '#FFAB00',
        deepBlack: '#0A0E1A',
        cardDark: '#141832',
        borderDark: '#1E2440',
      },
      fontFamily: {
        sans: ['Inter', 'sans-serif'],
      },
    },
  },
  plugins: [],
}
