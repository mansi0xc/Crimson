"use client"

import { motion } from "framer-motion"
import { FileText, ImageIcon, MessageSquare } from "lucide-react"
import { useEffect, useState } from "react"
import {Droplet,Heart,BlocksIcon} from "lucide-react"
export default function HeroAnimation() {
  const [isClient, setIsClient] = useState(false)

  useEffect(() => {
    setIsClient(true)
  }, [])

  if (!isClient) {
    return <div className="h-full w-full bg-gray-100 dark:bg-gray-800 rounded-xl"></div>
  }

  return (
    <div className="relative h-full w-full">
      {/* Background gradient */}
      <div className="absolute inset-0 bg-gradient-to-br from-primary/20 to-purple-100 dark:from-primary/10 dark:to-gray-800 rounded-xl" />

      {/* Floating elements */}
      <motion.div
        className="absolute top-10 left-10"
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.2 }}
      >
        <div className="bg-white dark:bg-gray-800 p-4 rounded-xl shadow-lg flex items-center gap-3 border border-gray-200 dark:border-gray-700">
          <div className="p-2 bg-blue-100 dark:bg-blue-900/30 rounded-lg">
            <Droplet className="h-6 w-6 text-red-600 dark:text-red-400" />
          </div>
          <div>
            <div className="text-sm font-medium">Blood Donation</div>
            <div className="text-xs text-gray-500 dark:text-gray-400"></div>
          </div>
        </div>
      </motion.div>

      <motion.div
        className="absolute bottom-20 left-20"
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.4 }}
      >
        <div className="bg-white dark:bg-gray-800 p-4 rounded-xl shadow-lg flex items-center gap-3 border border-gray-200 dark:border-gray-700">
          <div className="p-2 bg-green-100 dark:bg-green-900/30 rounded-lg">
            <Heart className="h-6 w-6 text-orange-600 dark:text-orange-400" />
          </div>
          <div>
            <div className="text-sm font-medium">Organ Donation</div>
            <div className="text-xs text-gray-500 dark:text-gray-400"></div>
          </div>
        </div>
      </motion.div>

      <motion.div
        className="absolute top-20 right-10"
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.6 }}
      >
        <div className="bg-white dark:bg-gray-800 p-4 rounded-xl shadow-lg flex items-center gap-3 border border-gray-200 dark:border-gray-700">
          <div className="p-2 bg-purple-100 dark:bg-purple-900/30 rounded-lg">
            <BlocksIcon className="h-6 w-6 text-purple-600 dark:text-purple-400" />
          </div>
          <div>
            <div className="text-sm font-medium">Blockchain</div>
            <div className="text-xs text-gray-500 dark:text-gray-400">Full Transperency</div>
          </div>
        </div>
      </motion.div>

      {/* Central element */}
      <motion.div
        className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2"
        initial={{ scale: 0.8, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        transition={{ delay: 0.8, type: "spring", stiffness: 100 }}
      >
        <div className="bg-white dark:bg-gray-800 p-6 rounded-full shadow-xl border-2 border-primary/50 h-32 w-32 flex items-center justify-center">
          <motion.div
            animate={{ rotate: 360 }}
            transition={{ duration: 20, repeat: Number.POSITIVE_INFINITY, ease: "linear" }}
          >
            <div className="relative h-24 w-24">
              <div className="absolute inset-0 rounded-full border-t-4 border-primary opacity-75"></div>
            </div>
          </motion.div>
          <div className="absolute inset-0 flex items-center justify-center">
            <motion.div initial={{ scale: 0 }} animate={{ scale: 1 }} transition={{ delay: 1, type: "spring" }}>
              <div className="text-primary font-bold text-lg">Crimson</div>
            </motion.div>
          </div>
        </div>
      </motion.div>

      {/* Connecting lines */}
      <svg className="absolute inset-0 w-full h-full" style={{ zIndex: -1 }}>
        <motion.path
          d="M120,100 Q200,150 240,200"
          stroke="currentColor"
          strokeWidth="2"
          fill="none"
          className="text-gray-300 dark:text-gray-700"
          initial={{ pathLength: 0, opacity: 0 }}
          animate={{ pathLength: 1, opacity: 1 }}
          transition={{ delay: 1.2, duration: 1 }}
        />
        <motion.path
          d="M240,200 Q280,250 120,300"
          stroke="currentColor"
          strokeWidth="2"
          fill="none"
          className="text-gray-300 dark:text-gray-700"
          initial={{ pathLength: 0, opacity: 0 }}
          animate={{ pathLength: 1, opacity: 1 }}
          transition={{ delay: 1.4, duration: 1 }}
        />
        <motion.path
          d="M240,200 Q300,150 350,120"
          stroke="currentColor"
          strokeWidth="2"
          fill="none"
          className="text-gray-300 dark:text-gray-700"
          initial={{ pathLength: 0, opacity: 0 }}
          animate={{ pathLength: 1, opacity: 1 }}
          transition={{ delay: 1.6, duration: 1 }}
        />
      </svg>
    </div>
  )
}

