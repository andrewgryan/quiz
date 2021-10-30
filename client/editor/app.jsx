import React from "react"
import ReactDOM from "react-dom"

console.log(React, ReactDOM)

const App = () => {
    return (
        <div className="min-h-screen bg-hero-topography bg-gray-800 flex flex-col justify-center items-center">
            <h1 className="text-3xl font-semibold p-2 rounded bg-gray-200 opacity-75 backdrop-blur-lg">Hello, React!</h1>
        </div>)
}

ReactDOM.render(<App />,
    document.getElementById("react-app"))
