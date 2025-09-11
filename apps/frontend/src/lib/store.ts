import { create } from 'zustand'
import { persist } from 'zustand/middleware'

interface User {
  id: string
  walletAddress?: string
  email?: string
  phone?: string
  createdAt: Date
}

interface Activity {
  id: string
  type: 'intro' | 'payment' | 'join'
  amount?: number
  description: string
  timestamp: Date
  status: 'pending' | 'completed' | 'failed'
}

interface PayLink {
  id: string
  amount: number
  description: string
  merchantId: string
  qrCode?: string
  url: string
  createdAt: Date
  expiresAt?: Date
}

interface AppState {
  // User state
  user: User | null
  isAuthenticated: boolean
  
  // Activity tracking
  activities: Activity[]
  
  // Pay links
  payLinks: PayLink[]
  
  // UI state
  isLoading: boolean
  error: string | null
  
  // Actions
  setUser: (user: User | null) => void
  addActivity: (activity: Omit<Activity, 'id' | 'timestamp'>) => void
  addPayLink: (payLink: Omit<PayLink, 'id' | 'createdAt'>) => void
  setLoading: (loading: boolean) => void
  setError: (error: string | null) => void
  clearError: () => void
}

export const useAppStore = create<AppState>()(
  persist(
    (set) => ({
      // Initial state
      user: null,
      isAuthenticated: false,
      activities: [],
      payLinks: [],
      isLoading: false,
      error: null,

      // Actions
      setUser: (user) => set({ user, isAuthenticated: !!user }),
      
      addActivity: (activity) => set((state) => ({
        activities: [
          {
            ...activity,
            id: Math.random().toString(36).substr(2, 9),
            timestamp: new Date()
          },
          ...state.activities
        ].slice(0, 100) // Keep only last 100 activities
      })),
      
      addPayLink: (payLink) => set((state) => ({
        payLinks: [
          {
            ...payLink,
            id: Math.random().toString(36).substr(2, 9),
            createdAt: new Date()
          },
          ...state.payLinks
        ]
      })),
      
      setLoading: (isLoading) => set({ isLoading }),
      setError: (error) => set({ error }),
      clearError: () => set({ error: null })
    }),
    {
      name: 'unykorn-app-store',
      partialize: (state) => ({
        user: state.user,
        activities: state.activities,
        payLinks: state.payLinks
      })
    }
  )
)