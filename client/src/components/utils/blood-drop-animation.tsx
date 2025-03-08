"use client"

import { useEffect, useRef } from "react"

export function BloodDropAnimation() {
  const canvasRef = useRef<HTMLCanvasElement>(null)

  useEffect(() => {
    const canvas = canvasRef.current
    if (!canvas) return

    const ctx = canvas.getContext("2d")
    if (!ctx) return

    // Set canvas dimensions
    canvas.width = 200
    canvas.height = 400

    // Blood drop properties
    const drops: {
      x: number
      y: number
      radius: number
      speed: number
      opacity: number
    }[] = []

    // Create initial drops
    for (let i = 0; i < 5; i++) {
      createDrop()
    }

    function createDrop() {
      drops.push({
        x: Math.random() * canvas.width,
        y: -20 - Math.random() * 100,
        radius: 5 + Math.random() * 10,
        speed: 1 + Math.random() * 3,
        opacity: 0.7 + Math.random() * 0.3,
      })
    }

    // Animation loop
    let animationId: number
    function animate() {
      ctx.clearRect(0, 0, canvas.width, canvas.height)

      // Update and draw drops
      for (let i = 0; i < drops.length; i++) {
        const drop = drops[i]

        // Update position
        drop.y += drop.speed

        // Draw drop
        ctx.beginPath()
        ctx.arc(drop.x, drop.y, drop.radius, 0, Math.PI * 2)
        ctx.fillStyle = `rgba(220, 38, 38, ${drop.opacity})`
        ctx.fill()

        // Remove drops that have fallen out of view
        if (drop.y > canvas.height + drop.radius) {
          drops.splice(i, 1)
          i--

          // Create a new drop
          createDrop()
        }
      }

      // Add new drops occasionally
      if (Math.random() < 0.03 && drops.length < 15) {
        createDrop()
      }

      animationId = requestAnimationFrame(animate)
    }

    animate()

    return () => {
      cancelAnimationFrame(animationId)
    }
  }, [])

  return <canvas ref={canvasRef} className="absolute -top-10 right-0 z-10 pointer-events-none opacity-70" />
}


