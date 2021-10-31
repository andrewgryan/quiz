module.exports = {
    mode: "jit",
    purge: [
        "client/index.html",
        "client/src/**/*.elm",
        "client/editor/index.html",
        "client/editor/**/*jsx"],
    darkMode: false, // or 'media' or 'class'
    theme: {
        extend: {},
    },
    variants: {
        extend: {},
    },
    plugins: [
        require("tailwind-heropatterns")({
            patterns: ["topography"],
            colors: {
                default: "#9C92AC"
            }
        }),
        require("@tailwindcss/forms")
    ],
}
