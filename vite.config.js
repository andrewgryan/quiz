import { resolve } from "path"
import { defineConfig } from "vite"
import elmPlugin from "vite-plugin-elm"

export default defineConfig({
    root: "client",
    plugins: [elmPlugin()],
    build: {
        rollupOptions: {
            input: {
                main: resolve(__dirname, "client/index.html"),
                editor: resolve(__dirname, "client/editor/index.html"),
            }
        }
    }
})
