

"use client";
import Link from "next/link"
import Image from "next/image"
import { Heart, Droplet, MapPin, Building2, Award, ChevronRight, ArrowRight, CheckCircle } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"

import { AnimatedTestimonials } from "@/components/ui/animated-testimonials";

import HeroAnimation from "@/components/utils/hero-animation";
  const testimonials = [
    {
      quote:
        "Crimson is a game-changer in blood donation, making the process transparent and rewarding. The NFT rewards add a unique touch, encouraging more people to donate regularly.",
      name: "Sarah Chen",
      designation: "Product Manager at TechFlow",
      src: "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=3560&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    },
    {
      quote:
        "The platform is well-designed, and setting up blood donation camps is super easy for hospitals. As a donor, I love the idea of getting NFTs as a token of appreciation!",
      name: "Michael Rodriguez",
      designation: "CTO at InnovateSphere",
      src: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=3540&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    },
    {
      quote:
        "Blockchain technology ensures that all donations and camps are verified, which builds trust. The NFT system is a great motivator and makes me feel valued as a donor",
      name: "Emily Watson",
      designation: "Operations Director at CloudScale",
      src: "https://images.unsplash.com/photo-1623582854588-d60de57fa33f?q=80&w=3540&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    },
    {
      quote:
        "Crimson is an amazing mix of blockchain innovation and social good. It's rewarding to donate and collect NFTs while knowing I’m making a difference!",
      name: "James Kim",
      designation: "Engineering Lead at DataPro",
      src: "https://images.unsplash.com/photo-1636041293178-808a6762ab39?q=80&w=3464&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    },
    {
      quote:
        "The scalability and performance have been game-changing for our organization. Highly recommend to any growing business.",
      name: "Lisa Thompson",
      designation: "VP of Technology at FutureNet",
      src: "https://images.unsplash.com/photo-1624561172888-ac93c696e10c?q=80&w=2592&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    },
  ];

export default function Home() {
  return (
    <div className="flex min-h-screen flex-col">
      
      <main className="flex-1">
        <section className="relative overflow-hidden py-20 md:py-32 bg-white">
          <div className="container relative z-10">
            <div className="grid gap-12 lg:grid-cols-2 lg:gap-8 items-center">
              <div className="space-y-6">
                <div className="inline-block rounded-lg bg-red-100 px-3 py-1 text-sm text-red-600 mb-4">
                  Blockchain-Powered Donation Platform
                </div>
                <h1 className="text-4xl font-bold tracking-tighter sm:text-5xl md:text-6xl">
                  Be the Reason <span className="text-red-600">Someone Lives</span>
                </h1>
                <p className="text-lg text-gray-600 max-w-[600px]">
                  Crimson connects hospitals, NGOs, and donors in a seamless ecosystem, ensuring every donation is
                  meticulously recorded and incentivized through blockchain technology.
                </p>
                <div className="flex flex-col sm:flex-row gap-4">
                  <Button className="bg-red-600 hover:bg-red-700 h-12 px-6">Become a Donor</Button>
                  <Button variant="outline" className="h-12 px-6 group">
                    Learn More
                    <ChevronRight className="ml-2 h-4 w-4 group-hover:translate-x-1 transition-transform" />
                  </Button>
                </div>
                <div className="flex items-center gap-4 pt-4">
                  <div className="flex -space-x-2">
                    
                  </div>
                  <p className="text-sm text-gray-600">
                    <span className="font-medium">1,000+</span> donors already joined
                  </p>
                </div>
              </div>
              <HeroAnimation/>
            </div>
          </div>
          <div className="absolute inset-0 bg-[url('/placeholder.svg?height=200&width=200&text=Pattern')] opacity-5"></div>
        </section>

        <div id="features" className="py-20 bg-gray-50">
          <div className="container">
            <div className="text-center max-w-3xl mx-auto mb-16">
              <h2 className="text-3xl font-bold tracking-tight sm:text-4xl mb-4">
                Powered by <span className="text-red-600">Blockchain</span> Technology
              </h2>
              <p className="text-lg text-gray-600">
                Our platform ensures transparency, security, and incentives for every donation through innovative
                blockchain solutions.
              </p>
            </div>
            <div className="grid gap-8 md:grid-cols-2 lg:grid-cols-4">
              {[
                {
                  icon: <Building2 className="h-10 w-10 text-red-600" />,
                  title: "Hospital Blood Camps",
                  description: "Hospitals can create and manage blood camps through our secure blockchain network.",
                },
                {
                  icon: <MapPin className="h-10 w-10 text-red-600" />,
                  title: "Interactive Maps",
                  description: "Find nearby blood camps and donation centers with our interactive mapping system.",
                },
                {
                  icon: <Heart className="h-10 w-10 text-red-600" />,
                  title: "Organ Donation",
                  description: "Transparent organ donation process secured by blockchain verification.",
                },
                {
                  icon: <Award className="h-10 w-10 text-red-600" />,
                  title: "NFT Rewards",
                  description: "Receive unique NFTs for successful blood and organ donations as recognition.",
                },
              ].map((feature, index) => (
                <Card key={index} className="group hover:shadow-lg transition-all duration-300 border-none bg-white">
                  <CardContent className="p-6">
                    <div className="mb-4 rounded-full bg-red-100 p-3 w-fit group-hover:bg-red-200 transition-colors">
                      {feature.icon}
                    </div>
                    <h3 className="text-xl font-bold mb-2">{feature.title}</h3>
                    <p className="text-gray-600">{feature.description}</p>
                  </CardContent>
                </Card>
              ))}
            </div>
          </div>
        </div>

        <div id="how-it-works" className="py-20 bg-white">
          <div className="container">
            <div className="text-center max-w-3xl mx-auto mb-16">
              <h2 className="text-3xl font-bold tracking-tight sm:text-4xl mb-4">
                How <span className="text-red-600">Crimson</span> Works
              </h2>
              <p className="text-lg text-gray-600">
                Our blockchain platform simplifies the donation process while ensuring security and transparency.
              </p>
            </div>
            <div className="grid gap-10 lg:grid-cols-3">
              {[
                {
                  step: "01",
                  title: "Register on Platform",
                  description: "Create your secure account as a donor, hospital, or NGO with blockchain verification.",
                },
                {
                  step: "02",
                  title: "Find or Create Donation Events",
                  description: "Locate nearby donation camps or create new ones through our blockchain network.",
                },
                {
                  step: "03",
                  title: "Donate & Receive Rewards",
                  description: "Complete your donation and receive NFT certificates and rewards for your contribution.",
                },
              ].map((step, index) => (
                <div key={index} className="relative">
                  <div className="flex flex-col items-center text-center">
                    <div className="flex h-16 w-16 items-center justify-center rounded-full bg-red-100 text-red-600 font-bold text-xl mb-6">
                      {step.step}
                    </div>
                    <h3 className="text-xl font-bold mb-2">{step.title}</h3>
                    <p className="text-gray-600">{step.description}</p>
                  </div>
                  {index < 2 && (
                    <div className="hidden lg:block absolute top-8 left-[calc(100%-_16px)] w-[calc(100%-_32px)] h-[2px] bg-red-200">
                      <ArrowRight className="absolute right-0 top-1/2 -translate-y-1/2 text-red-300" />
                    </div>
                  )}
                </div>
              ))}
            </div>
          </div>
        </div>

        <div id="benefits" className="py-20 bg-gradient-to-b from-gray-50 to-white">
          <div className="container">
            <div className="grid gap-12 lg:grid-cols-2 items-center">
              <div>
              <AnimatedTestimonials testimonials={testimonials} />;
              </div>
              <div className="space-y-8">
                <div>
                  <h2 className="text-3xl font-bold tracking-tight sm:text-4xl mb-4">
                    Why Choose <span className="text-red-600">Crimson</span>?
                  </h2>
                  <p className="text-lg text-gray-600">
                    Our blockchain platform offers unique advantages for all participants in the donation ecosystem.
                  </p>
                </div>
                <div className="space-y-6">
                  {[
                    {
                      title: "Complete Transparency",
                      description:
                        "Every donation is recorded on the blockchain, ensuring full transparency and traceability.",
                    },
                    {
                      title: "Fraud Prevention",
                      description: "Our blockchain technology proactively flags and prevents fraudulent activities.",
                    },
                    {
                      title: "Incentive System",
                      description: "Donors receive NFT rewards and recognition for their life-saving contributions.",
                    },
                    {
                      title: "Seamless Coordination",
                      description: "Hospitals, NGOs, and donors can coordinate efficiently through our platform.",
                    },
                  ].map((benefit, index) => (
                    <div key={index} className="flex gap-4">
                      <div className="mt-1 flex-shrink-0">
                        <CheckCircle className="h-6 w-6 text-red-600" />
                      </div>
                      <div>
                        <h3 className="text-lg font-medium mb-1">{benefit.title}</h3>
                        <p className="text-gray-600">{benefit.description}</p>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </div>

        <div id="testimonials" className="py-20 bg-white">
          <div className="container">
            <div className="text-center max-w-3xl mx-auto mb-16">
              <h2 className="text-3xl font-bold tracking-tight sm:text-4xl mb-4">
                Success <span className="text-red-600">Stories</span>
              </h2>
              <p className="text-lg text-gray-600">
                Hear from the people who have experienced the impact of Crimson's blockchain donation platform.
              </p>
            </div>
            <div className="grid gap-8 md:grid-cols-2 lg:grid-cols-3">
              {[
                {
                  name: "Sarah Johnson",
                  role: "Regular Blood Donor",
                  image: "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=3560&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                  quote:
                    "The NFT rewards make donating blood even more rewarding. I love seeing my contribution tracked on the blockchain!",
                },
                {
                  name: "Dr. Michael Chen",
                  role: "Hospital Administrator",
                  image: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=3540&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                  quote:
                    "Crimson has revolutionized how we organize blood camps. The blockchain verification gives donors confidence in our process.",
                },
                {
                  name: "Priya Sharma",
                  role: "NGO Coordinator",
                  image: "https://images.unsplash.com/photo-1624561172888-ac93c696e10c?q=80&w=2592&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                  quote:
                    "The transparency of Crimson's blockchain platform has helped us build trust with our donors and hospital partners.",
                },
              ].map((testimonial, index) => (
                <Card key={index} className="bg-gray-50 border-none">
                  <CardContent className="p-6">
                    <div className="flex items-center gap-4 mb-4">
                      <div className="h-12 w-12 rounded-full overflow-hidden">
                        <img
                          src={testimonial.image || "/placeholder.svg"}
                          alt={testimonial.name}
                          width={48}
                          height={48}
                        />
                      </div>
                      <div>
                        <h3 className="font-medium">{testimonial.name}</h3>
                        <p className="text-sm text-gray-600">{testimonial.role}</p>
                      </div>
                    </div>
                    <p className="text-gray-600 italic">"{testimonial.quote}"</p>
                  </CardContent>
                </Card>
              ))}
            </div>
          </div>
        </div>

        <div className="py-20 bg-red-600 text-white">
          <div className="container">
            <div className="grid gap-8 lg:grid-cols-2 items-center">
              <div className="space-y-4">
                <h2 className="text-3xl font-bold tracking-tight sm:text-4xl">Ready to make a difference?</h2>
                <p className="text-xl opacity-90">
                  Join Crimson today and be part of our blockchain-powered donation ecosystem.
                </p>
              </div>
              <div className="flex flex-col sm:flex-row gap-4 justify-end">
                <Button
                  variant="outline"
                  className="bg-transparent text-white border-white hover:bg-white/10 h-12 px-6"
                >
                  Learn More
                </Button>
                <Button className="bg-white text-red-600 hover:bg-gray-100 h-12 px-6">Register Now</Button>
              </div>
            </div>
          </div>
        </div>

        
        
      </main>
      <footer className="bg-gray-900 text-gray-300 py-12">
        <div className="container">
          <div className="grid gap-8 md:grid-cols-2 lg:grid-cols-4 mb-8">
            <div>
              <div className="flex items-center gap-2 mb-4">
                <Droplet className="h-6 w-6 text-red-500" />
                <span className="text-xl font-bold text-white">Crimson</span>
              </div>
              <p className="text-sm mb-4">
                Blockchain-powered platform transforming the landscape of blood and organ donation.
              </p>
              <div className="flex gap-4">
                {["twitter", "facebook", "instagram", "linkedin"].map((social) => (
                  <Link
                    key={social}
                    href={`#${social}`}
                    className="h-8 w-8 rounded-full bg-gray-800 flex items-center justify-center hover:bg-red-600 transition-colors"
                  >
                    <span className="sr-only">{social}</span>
                    <div className="h-4 w-4" />
                  </Link>
                ))}
              </div>
            </div>
            <div>
              <h3 className="font-bold text-white mb-4">Features</h3>
              <ul className="space-y-2">
                {["Blood Donation", "Organ Donation", "Hospital Network", "NFT Rewards", "Blockchain Security"].map(
                  (item) => (
                    <li key={item}>
                      <Link href="#" className="text-sm hover:text-red-500 transition-colors">
                        {item}
                      </Link>
                    </li>
                  ),
                )}
              </ul>
            </div>
            <div>
              <h3 className="font-bold text-white mb-4">Resources</h3>
              <ul className="space-y-2">
                {["Documentation", "API", "Partners", "Blog", "News"].map((item) => (
                  <li key={item}>
                    <Link href="#" className="text-sm hover:text-red-500 transition-colors">
                      {item}
                    </Link>
                  </li>
                ))}
              </ul>
            </div>
            <div>
              <h3 className="font-bold text-white mb-4">Contact</h3>
              <ul className="space-y-2">
                <li className="flex items-start gap-2 text-sm">
                  <MapPin className="h-5 w-5 text-red-500 flex-shrink-0 mt-0.5" />
                  <span>123 Blockchain Avenue, Digital City</span>
                </li>
                <li className="flex items-center gap-2 text-sm">
                  <svg className="h-5 w-5 text-red-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"
                    />
                  </svg>
                  <span>contact@Crimson.org</span>
                </li>
                <li className="flex items-center gap-2 text-sm">
                  <svg className="h-5 w-5 text-red-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z"
                    />
                  </svg>
                  <span>+1 (555) 123-4567</span>
                </li>
              </ul>
            </div>
          </div>
          <div className="pt-8 border-t border-gray-800 text-sm text-center">
            <p>&copy; 9th March 2025 Crimson. All rights reserved.</p>
          </div>
        </div>
      </footer>
    </div>
  )
}