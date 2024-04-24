module.exports = {
  content: ["**/*.eml"],
  theme: {
    extend: {
      colors: {
        orange: '#FF9800',
        darkOrange: '#EB7F00',
        primary: '#181818',
        body: '#333333',
        darkGrey: '#4D4D4D',
        grey: '#7B7B7B',
        offwhite: '#F3F3F3',
        lightGray: '#B7B7B7',
        darkGreen: '#17819A',
        blue: '#4DB1B8',
        green: '#AFE0D5',
        cyan: '#C5F0FB'
      },
      fontFamily: {
        space: ['Space Grotesk'],
        inter: ['Inter'],
      },
      typography: (theme) => ({
        DEFAULT: {
          css: [{
            'code::before': {
              content: '""',
            },
            'code::after': {
              content: '""',
            },
            h1: {
              fontWeight: 700,
            },
            code: {
              fontSize: "1em",
            },
            'h2 code': {
              fontSize: "1em",
            },
            'h3 code': {
              fontSize: "1em",
            },
          }]
        },
        sm: {
          css: {
            code: {
              fontSize: "1em",
            },
          },
        }
      }),
    },
  },
  plugins: [
    require("@tailwindcss/typography"),
  ],
}
