import React, { useState } from "react"
import ReactDOM from "react-dom"
import {
    LightBulbIcon,
    CameraIcon,
    ArrowRightIcon,
    CloudUploadIcon,
    TrashIcon,
    MinusCircleIcon,
    PlusCircleIcon,
    BadgeCheckIcon,
    XCircleIcon,
} from "@heroicons/react/solid"
import { Listbox } from "@headlessui/react"

console.log(React, ReactDOM)

const App = () => {
    return (
        <div className="min-h-screen bg-hero-topography bg-gray-900 flex flex-col justify-center items-center">

            <div className="relative">

                {/* Background card effect */}
                <div className="absolute -bottom-4 inset-x-0 h-full bg-white/10 backdrop-blur-md rounded scale-[0.85] origin-bottom" />

                {/* Background card effect */}
                <div className="absolute -bottom-2 inset-x-0 h-full bg-white/30 backdrop-blur-md rounded scale-95 origin-bottom shadow-sm" />

                {/* Main interface */}
                <div className="relative flex flex-col space-y-6 bg-gray-800 border border-gray-700 text-white p-2 rounded shadow-sm">

                    {/* Editor card */}
                    <div className="flex flex-row justify-between items-center">
                        <div className="font-semibold text-xl uppercase leading-wider">
            Editor
                        </div>
                        <div className="flex flex-row space-x-2 items-center bg-red-400 text-white px-2 py-1.5 rounded">
                            <div className="uppercase font-light text-sm tracking-wide">Upload</div>
                            <CloudUploadIcon className="h-4 w-4" />
                        </div>
                    </div>
                    <div className="flex flex-col space-y-1">
                        <label htmlFor="question" className="block">
                            <div className="flex flex-row justify-between items-center">
                                <span className="text-gray-100">Question</span>
                                <span className="text-gray-100 text-xs">0/1</span>
                            </div>
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
                            <div className="flex flex-row items-center space-x-1">
                                <EditAnswer />
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
                        <div className="bg-gray-600 w-full py-2 rounded flex flex-row justify-center items-center space-x-2 cursor-pointer hover:opacity-75">
                            <div>Next question</div>
                            <ArrowRightIcon className="h-4 w-4" />
                        </div>
                    </div>
                </div>
            </div>

            {/* Extra navigation items */}
            <div className="absolute bottom-0 inset-x-0 h-20">
                <div className="flex flex-row justify-between px-10">
                    <button className="bg-gray-800/40 backdrop-blur-md rounded-full p-2"><LightBulbIcon className="h-6 w-6 text-white" /></button>
                    <button className="bg-gray-800/40 backdrop-blur-md rounded-full p-2"><CameraIcon className="h-6 w-6 text-white" /></button>
                </div>
            </div>

        </div>
    )
}

const EditAnswer = () => {
    const icons = [
        <div key={ 0 } className="px-2 hover:opacity-75 cursor-pointer text-red-300">
            <XCircleIcon className="h-5 w-5" />
        </div>,
        <div key={ 1 } className="px-2 hover:opacity-75 cursor-pointer text-green-300">
            <BadgeCheckIcon className="h-5 w-5" />
        </div>
    ]
    const choices = [ 0, 1 ]
    const [ index, setIndex ] = useState(0)
    return (
        <Listbox as="div" value={ index } onChange={ setIndex } className="relative">
            <Listbox.Button>{ icons[index] }</Listbox.Button>
            <Listbox.Options className="absolute bg-gray-700 border border-gray-600 py-2 rounded flex flex-col space-y-1">{ choices.map((_, idx) => {
                return (
                    <Listbox.Option value={ idx } key={ idx }>{ icons[idx] }</Listbox.Option>
                )
            }) }</Listbox.Options>
        </Listbox>)
}


ReactDOM.render(<App />, document.getElementById("react-app"))
