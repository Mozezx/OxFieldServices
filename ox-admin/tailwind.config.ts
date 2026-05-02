import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './app/**/*.{ts,tsx}',
    './components/**/*.{ts,tsx}',
    './lib/**/*.{ts,tsx}',
  ],
  theme: {
    extend: {
      colors: {
        primary:           '#092F3D',
        secondary:         '#FFFFFF',
        accent:            '#03FC30',
        surface:           '#0D3F52',
        surface2:          '#0A4A62',
        error:             '#FF4C4C',
        warning:           '#FFA500',
        divider:           '#1A5570',
        'text-secondary':  '#A8C4CE',
        'text-disabled':   '#4A7A8A',
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
      borderRadius: {
        card:  '16px',
        btn:   '12px',
        input: '12px',
      },
    },
  },
  plugins: [],
}

export default config
