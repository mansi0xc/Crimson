"use client"

import { cn } from "@/lib/utils"
import { useChat } from "ai/react"
import { FileUp, Loader2, Send, X, MessageCircle } from "lucide-react"
import Image from "next/image"
import type React from "react"
import { useEffect, useRef, useState } from "react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import ReactMarkdown from "react-markdown"

export default function Chat() {
  const { messages, input, handleInputChange, handleSubmit, isLoading } = useChat({
    api: "api/chat",
  })
  const [files, setFiles] = useState<FileList | undefined>(undefined)
  const [previews, setPreviews] = useState<string[]>([])
  const [pdfPreviews, setPdfPreviews] = useState<{ name: string; size: number; url: string }[]>([])
  const [activePdf, setActivePdf] = useState<string | null>(null)
  const [isUploading, setIsUploading] = useState(false)
  const fileInputRef = useRef<HTMLInputElement>(null)
  const messagesEndRef = useRef<HTMLDivElement>(null)
  const formRef = useRef<HTMLFormElement>(null)
  const scrollAreaRef = useRef<HTMLDivElement>(null)
  const [isOpen, setIsOpen] = useState(false)
  const chatContainerRef = useRef<HTMLDivElement>(null)
  // Auto-scroll to bottom when new messages arrive
  const scrollToBottom = () => {
    if (scrollAreaRef.current) {
      scrollAreaRef.current.scrollTop = scrollAreaRef.current.scrollHeight
    }
  }

  useEffect(() => {
    scrollToBottom()
  }, [messages])

  // Generate image previews when files are selected
  useEffect(() => {
    if (!files) {
      setPreviews([])
      setPdfPreviews([])
      return
    }

    const newPreviews: string[] = []
    const newPdfPreviews: { name: string; size: number; url: string }[] = []
    setIsUploading(true)

    Array.from(files).forEach((file) => {
      if (file.type.startsWith("image/")) {
        const reader = new FileReader()
        reader.onload = (e) => {
          if (e.target?.result) {
            setPreviews((prev) => [...prev, e.target!.result as string])
          }
        }
        reader.readAsDataURL(file)
      } else if (file.type.startsWith("application/pdf")) {
        const reader = new FileReader()
        reader.onload = (e) => {
          if (e.target?.result) {
            const url = URL.createObjectURL(file)
            newPdfPreviews.push({ name: file.name, size: file.size, url })
            setPdfPreviews(newPdfPreviews)
          }
        }
        reader.readAsDataURL(file)
      }
    })

    setIsUploading(false)
  }, [files])

  const handleFileChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    if (event.target.files) {
      setFiles(event.target.files)
    }
  }

  const clearFiles = () => {
    setFiles(undefined)
    setPreviews([])
    setPdfPreviews([])
    if (fileInputRef.current) {
      fileInputRef.current.value = ""
    }
  }

  const onSubmit = (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault()

    if (!input && (!files || files.length === 0)) return

    handleSubmit(event, {
      experimental_attachments: files,
    })

    clearFiles()
  }

  const handlePdfClick = (url: string) => {
    setActivePdf(url === activePdf ? null : url)
  }
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      const target = event.target as HTMLElement
      const button = document.querySelector('button[class*="fixed bottom-4 right-4"]')

      if (
        chatContainerRef.current &&
        !chatContainerRef.current.contains(target) &&
        button &&
        !button.contains(target)
      ) {
        setIsOpen(false)
      }
    }

    document.addEventListener("mousedown", handleClickOutside)
    return () => {
      document.removeEventListener("mousedown", handleClickOutside)
    }
  }, [])

  const toggleChat = () => setIsOpen(!isOpen)
  return (
    <>
      <Button
        size="lg"
        className={cn(
          "fixed bottom-4 right-4 rounded-full p-4 shadow-lg transition-transform hover:scale-105",
          isOpen && "rotate-90",
        )}
        onClick={toggleChat}
      >
        <MessageCircle className="h-6 w-6" />
      </Button>
      <div
        ref={chatContainerRef}
        className={cn(
          "fixed bottom-20 right-4 w-[380px] h-[500px] transition-all duration-300 ease-in-out bg-white shadow-md rounded-sm z-10",
          isOpen ? "translate-y-0 opacity-100" : "translate-y-4 opacity-0 pointer-events-none",
        )}
      >
        {/* Header */}
        <div className="p-4 border-b">
          <h1 className="text-xl font-bold">Elixir Assistant</h1>
        </div>

        {/* Messages */}
        <div className="h-[calc(100%-140px)] overflow-y-auto p-4" ref={scrollAreaRef}>
          {messages.map((message) => (
            <div key={message.id} className={cn("mb-4 max-w-[80%]", message.role === "user" ? "ml-auto" : "mr-auto")}>
              <div
                className={cn(
                  "rounded-3xl px-4 py-3 shadow-sm",
                  message.role === "user" ? "bg-[#f44336] text-white" : "bg-[#f0f0f0] text-gray-700",
                )}
              >
                <div className="whitespace-pre-wrap break-words">
                  <ReactMarkdown>{message.content}</ReactMarkdown>
                </div>

                {/* Attachments */}
                {(message.experimental_attachments || []).filter(
                  (attachment) =>
                    attachment?.contentType?.startsWith("image/") ||
                    attachment?.contentType?.startsWith("application/pdf"),
                ).length > 0 && (
                  <div className="mt-3 space-y-2">
                    {/* Images */}
                    {(message?.experimental_attachments || [])
                      .filter((attachment) => attachment?.contentType?.startsWith("image/"))
                      .map((attachment, index) => (
                        <div
                          key={`${message.id}-${index}`}
                          className="relative rounded-md overflow-hidden border shadow-sm"
                        >
                          <Image
                            src={attachment.url || "/placeholder.svg"}
                            width={300}
                            height={300}
                            alt={attachment.name ?? `attachment-${index}`}
                            className="object-contain max-h-[300px] w-auto rounded-md"
                          />
                        </div>
                      ))}

                    {/* PDFs */}
                    {(message?.experimental_attachments || [])
                      .filter((attachment) => attachment?.contentType?.startsWith("application/pdf"))
                      .map((attachment, index) => (
                        <div
                          key={`pdf-${message.id}-${index}`}
                          className="relative rounded-md overflow-hidden border shadow-sm cursor-pointer hover:bg-gray-100 transition-colors"
                          onClick={() => handlePdfClick(attachment.url)}
                        >
                          <div className="flex items-center gap-3 p-3">
                            <div className="bg-gray-100 p-2 rounded">
                              <FileUp className="h-6 w-6 text-gray-600" />
                            </div>
                            <div className="flex-1 truncate">
                              <p className="font-medium text-sm">{attachment.name || `Document-${index}.pdf`}</p>
                              <p className="text-xs text-gray-500">Click to view PDF</p>
                            </div>
                          </div>
                        </div>
                      ))}
                  </div>
                )}
              </div>
            </div>
          ))}

          {/* Loading indicator */}
          {isLoading && (
            <div className="mb-4 max-w-[80%]">
              <div className="bg-[#f0f0f0] rounded-3xl px-4 py-3 shadow-sm">
                <div className="flex space-x-2">
                  <div className="h-2 w-2 bg-gray-400 rounded-full animate-pulse"></div>
                  <div className="h-2 w-2 bg-gray-400 rounded-full animate-pulse delay-150"></div>
                  <div className="h-2 w-2 bg-gray-400 rounded-full animate-pulse delay-300"></div>
                </div>
              </div>
            </div>
          )}

          <div ref={messagesEndRef} />
        </div>

        {/* File previews */}
        {(previews.length > 0 || pdfPreviews.length > 0) && (
          <div className="px-4 py-2 border-t bg-gray-50">
            <div className="flex items-center gap-3 overflow-x-auto pb-1">
              {previews.map((preview, index) => (
                <div key={index} className="relative h-16 w-16 flex-shrink-0">
                  <div className="absolute inset-0 rounded-md overflow-hidden border shadow-sm">
                    <Image
                      src={preview || "/placeholder.svg"}
                      alt={`Preview ${index}`}
                      fill
                      className="object-cover rounded-md"
                    />
                  </div>
                  <button
                    type="button"
                    onClick={clearFiles}
                    className="absolute -top-2 -right-2 bg-red-500 text-white rounded-full p-1 shadow-md"
                  >
                    <X className="h-3 w-3" />
                  </button>
                </div>
              ))}
              {pdfPreviews.map((pdfPreview, index) => (
                <div key={`pdf-${index}`} className="relative h-16 w-16 flex-shrink-0">
                  <div className="flex flex-col items-center justify-center h-full w-full bg-gray-100 rounded-md border overflow-hidden">
                    <FileUp className="h-5 w-5 text-gray-600 mb-1" />
                    <div className="bg-white w-full p-1 text-[8px] text-center font-medium text-gray-700 truncate">
                      {pdfPreview.name.length > 10 ? pdfPreview.name.substring(0, 8) + "..." : pdfPreview.name}
                    </div>
                  </div>
                  <button
                    type="button"
                    onClick={() => {
                      const updatedPdfPreviews = pdfPreviews.filter((p) => p.url !== pdfPreview.url)
                      setPdfPreviews(updatedPdfPreviews)
                    }}
                    className="absolute -top-2 -right-2 bg-red-500 text-white rounded-full p-1 shadow-md"
                  >
                    <X className="h-3 w-3" />
                  </button>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Upload indicator */}
        {isUploading && previews.length === 0 && pdfPreviews.length === 0 && (
          <div className="flex items-center justify-center gap-2 py-2 border-t">
            <Loader2 className="h-4 w-4 animate-spin text-gray-500" />
            <span className="text-xs text-gray-500">Processing files...</span>
          </div>
        )}

        {/* Input form */}
        <div className="p-4 border-t">
          <form ref={formRef} onSubmit={onSubmit} className="flex items-center gap-2">
            <div className="relative flex-1">
              <Input
                value={input}
                onChange={handleInputChange}
                placeholder="Type your message..."
                className="pr-5 ml-8 py-6 rounded-full w-64 border-gray-300 focus:border-gray-400 focus:ring-0"
              />
              <button
                type="button"
                className="absolute -left-1 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600"
                onClick={() => fileInputRef.current?.click()}
              >
                <FileUp className="h-5 w-5" />
                <span className="sr-only">Upload file</span>
              </button>
            </div>

            <Button
              type="submit"
              size="icon"
              className="h-12 w-12 rounded-full bg-[#f44336] hover:bg-[#e53935] shadow-md"
              disabled={isLoading || (!input && (!files || files.length === 0))}
            >
              {isLoading ? <Loader2 className="h-5 w-5 animate-spin" /> : <Send className="h-5 w-5" />}
              <span className="sr-only">Send message</span>
            </Button>

            <input
              type="file"
              ref={fileInputRef}
              onChange={handleFileChange}
              multiple
              accept="image/*,application/pdf"
              className="hidden"
            />
          </form>
        </div>

        {/* PDF Viewer Modal */}
        {activePdf && (
          <div
            className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4"
            onClick={() => setActivePdf(null)}
          >
            <div
              className="bg-white rounded-lg w-full max-w-4xl h-[80vh] overflow-hidden"
              onClick={(e) => e.stopPropagation()}
            >
              <div className="flex items-center justify-between p-2 border-b">
                <h3 className="font-medium">PDF Document</h3>
                <Button variant="ghost" size="icon" onClick={() => setActivePdf(null)}>
                  <X className="h-4 w-4" />
                </Button>
              </div>
              <iframe src={activePdf} className="w-full h-[calc(100%-3rem)]" title="PDF Viewer" />
            </div>
          </div>
        )}
      </div>
    </>
  )
}

