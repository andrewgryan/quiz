import React from "react"
import ReactDOM from "react-dom"
import {
    BeakerIcon,
    TrashIcon,
    MinusCircleIcon,
    PlusCircleIcon,
    BadgeCheckIcon,
    XCircleIcon,
} from "@heroicons/react/solid"

console.log(React, ReactDOM)

const App = () => {
    return (
        <div className="min-h-screen bg-hero-topography bg-gray-900 flex flex-col justify-center items-center">
            <div className="flex flex-col space-y-6 bg-gray-800 border border-gray-700 text-white p-2 rounded">
                <div className="flex flex-row justify-between items-center">
                    <div className="font-semibold text-xl uppercase leading-wider">
            Editor
                    </div>
                    <BeakerIcon className="h-5 w-5" />
                </div>
                <div className="flex flex-col space-y-1">
                    <label htmlFor="question" className="block">
                        <span className="text-gray-100">Enter question:</span>
                        <input className="mt-1 block w-full bg-gray-700" type="text" />
                    </label>
                    <label htmlFor="answer-0" className="block">
                        <span className="text-gray-100">Answers</span>
                        <div className="flex flex-row items-center space-x-1">
                            <div className="px-2 hover:opacity-75 cursor-pointer">
                                <XCircleIcon className="h-5 w-5 text-red-300" />
                            </div>
                            <input className="mt-1 flex-grow bg-gray-700" type="text" />
                            <div className="px-2 hover:opacity-75 cursor-pointer">
                                <TrashIcon className="h-5 w-5" />
                            </div>
                        </div>
                        <div className="flex flex-row items-center space-x-1">
                            <div className="px-2 hover:opacity-75 cursor-pointer text-red-300">
                                <XCircleIcon className="h-5 w-5" />
                            </div>
                            <input className="mt-1 flex-grow bg-gray-700" type="text" />
                            <div className="px-2 hover:opacity-75 cursor-pointer">
                                <TrashIcon className="h-5 w-5" />
                            </div>
                        </div>
                        <div className="flex flex-row items-center space-x-1">
                            <div className="px-2 hover:opacity-75 cursor-pointer text-green-300">
                                <BadgeCheckIcon className="h-5 w-5" />
                            </div>
                            <input className="mt-1 flex-grow bg-gray-700" type="text" />
                            <div className="px-2 hover:opacity-75 cursor-pointer">
                                <TrashIcon className="h-5 w-5" />
                            </div>
                        </div>
                        <div className="flex flex-row justify-center space-x-1 py-2 items-center">
                            <div className="px-2 hover:opacity-75 cursor-pointer">
                                <MinusCircleIcon className="h-5 w-5" />
                            </div>
                            <div className="px-2 hover:opacity-75 cursor-pointer">
                                <PlusCircleIcon className="h-5 w-5" />
                            </div>
                        </div>
                    </label>
                </div>
                <div className="flex flex-row justify-end">
                    <div className="bg-gray-600 w-full py-2 rounded flex flex-row justify-center cursor-pointer hover:opacity-75">
            Submit
                    </div>
                </div>
            </div>
        </div>
    )
}

ReactDOM.render(<App />, document.getElementById("react-app"))
