const colors = require('tailwindcss/colors');
const plugin = require('tailwindcss/plugin');

module.exports = {
  mode: 'jit',
  purge: ['./src/**/*.{js,jsx,ts,tsx}', './public/index.html'],
  theme: {
    extend: {
      boxShadow: {
        DEFAULT: '0 1px 3px 0 rgba(0, 0, 0, 0.08), 0 1px 2px 0 rgba(0, 0, 0, 0.02)',
        md: '0 4px 6px -1px rgba(0, 0, 0, 0.08), 0 2px 4px -1px rgba(0, 0, 0, 0.02)',
        lg: '0px 10px 30px -5px rgba(0, 0, 0, 0.5), 0 4px 6px -2px rgba(0, 0, 0, 0.1)',
        xl: '0 20px 25px -5px rgba(0, 0, 0, 0.08), 0 10px 10px -5px rgba(0, 0, 0, 0.01)',
      },
      colors: {
        gray: colors.blueGray,
        'light-blue': colors.sky,
        red: colors.rose,
        'primary': '#a100ff',
        'secondary': '#7500c0',
        'drei': "rgb(0, 0, 0, 0.2)",
        'vier': "#dcafff",
        "fuenf": "#e6dcff",
        "darker": "#2c3847",
        "ghBlack": "#0d1117",
        "ghBlack2": "#161b22",
        "ghBlack3": "#1f262e",
        "ghBlack4": "#2f3640",
        "kxBlue": "#5a86ff",
        "kxBlue2": "#3253ad",
        

        //Status Color
        "statusGreen": "#05f0a5",
        "statusOrange": "#ff7800",
        "statusRed": "#ff3246",
        "statusYellow": "#ffeb32",
        "statusGray": "#96968c",

        //ACN Colors
        "corePurple3": "#460073",
        "accentPurple1": "#b455aa",
        "accentPurple1dark": "#8c3083",
        "accentPurple3": "#be82ff",
        "accentPurple4": "#dcafff",
        "accentPurple5": "#e6dcff",
        "blueGreen": "#05f0a5", 
        "acnPink": "#ff50a0",
        "acnRed": "#ff3246",
        "acnRed2": "#cc2131",

        "inv1":"#222938",
        "inv2":"#293040",
        "inv3":"#263041",

        "statusNewGreen": "#90BE6D",
        "statusNewYellow": "#F9C74F",
        "statusNewOrange": "#F8961E",
        "statusNewRed": "#F94144"

      },
      outline: {
        blue: 'rgb(90, 134, 255)',
      },
      fontFamily: {
        inter: ['Inter', 'sans-serif'],
      },
      fontSize: {
        xs: ['0.75rem', { lineHeight: '1.5' }],
        sm: ['0.875rem', { lineHeight: '1.5715' }],
        base: ['1rem', { lineHeight: '1.5', letterSpacing: '-0.01em' }],
        lg: ['1.125rem', { lineHeight: '1.5', letterSpacing: '-0.01em' }],
        xl: ['1.25rem', { lineHeight: '1.5', letterSpacing: '-0.01em' }],
        '2xl': ['1.5rem', { lineHeight: '1.33', letterSpacing: '-0.01em' }],
        '3xl': ['1.88rem', { lineHeight: '1.33', letterSpacing: '-0.01em' }],
        '4xl': ['2.25rem', { lineHeight: '1.25', letterSpacing: '-0.02em' }],
        '5xl': ['3rem', { lineHeight: '1.25', letterSpacing: '-0.02em' }],
        '6xl': ['3.75rem', { lineHeight: '1.2', letterSpacing: '-0.02em' }],
      },
      screens: {
        xs: '480px',
      },
      borderWidth: {
        3: '3px',
      },
      minWidth: {
        36: '9rem',
        44: '11rem',
        56: '14rem',
        60: '15rem',
        72: '18rem',
        80: '20rem',
      },
      maxWidth: {
        '8xl': '88rem',
        '9xl': '96rem',
      },
      zIndex: {
        60: '60',
      },
    },
  },
  plugins: [
    // eslint-disable-next-line global-require
    require('@tailwindcss/forms'),
    // add custom variant for expanding sidebar
    plugin(({ addVariant, e }) => {
      addVariant('sidebar-expanded', ({ modifySelectors, separator }) => {
        modifySelectors(({ className }) => `.sidebar-expanded .${e(`sidebar-expanded${separator}${className}`)}`);
      });
    }),
  ],
};
