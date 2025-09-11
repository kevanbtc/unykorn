import { create } from 'zustand'
import { devtools, persist } from 'zustand/middleware'

export interface User {
  address?: string
  email?: string
  phone?: string
  name?: string
  isConnected: boolean
}

export interface Activity {
  id: string
  type: 'join' | 'payment' | 'referral' | 'connect'
  amount?: number
  description: string
  timestamp: Date
  status: 'pending' | 'completed' | 'failed'
}

export interface PayLink {
  id: string
  amount: number
  merchant: string
  description: string
  qrCode?: string
  shortUrl?: string
  pointOfInterest?: string
  createdAt: Date
  expiresAt?: Date
  isActive: boolean
}

export interface AppState {
  // User state
  user: User
  setUser: (user: Partial<User>) => void
  clearUser: () => void
  
  // Activity state
  activities: Activity[]
  addActivity: (activity: Omit<Activity, 'id' | 'timestamp'>) => void
  
  // Pay links state
  payLinks: PayLink[]
  addPayLink: (payLink: Omit<PayLink, 'id' | 'createdAt'>) => void
  togglePayLinkStatus: (id: string) => void
  
  // UI state
  isLoading: boolean
  setLoading: (loading: boolean) => void
  
  // Notifications
  notifications: Array<{
    id: string
    type: 'success' | 'error' | 'info' | 'warning'
    title: string
    message?: string
    timestamp: Date
  }>
  addNotification: (notification: {
    type: 'success' | 'error' | 'info' | 'warning'
    title: string
    message?: string
  }) => void
  removeNotification: (id: string) => void
}

export const useAppStore = create<AppState>()(
  devtools(
    persist(
      (set) => ({
        // Initial user state
        user: {
          isConnected: false
        },
        
        setUser: (userData) => 
          set((state) => ({
            user: { ...state.user, ...userData }
          }), false, 'setUser'),
          
        clearUser: () =>
          set(() => ({
            user: { isConnected: false }
          }), false, 'clearUser'),
        
        // Activity management
        activities: [],
        
        addActivity: (activity) =>
          set((state) => ({
            activities: [{
              ...activity,
              id: crypto.randomUUID(),
              timestamp: new Date()
            }, ...state.activities].slice(0, 100) // Keep last 100 activities
          }), false, 'addActivity'),
        
        // Pay links management
        payLinks: [],
        
        addPayLink: (payLinkData) =>
          set((state) => ({
            payLinks: [{
              ...payLinkData,
              id: crypto.randomUUID(),
              createdAt: new Date()
            }, ...state.payLinks]
          }), false, 'addPayLink'),
          
        togglePayLinkStatus: (id) =>
          set((state) => ({
            payLinks: state.payLinks.map(link =>
              link.id === id ? { ...link, isActive: !link.isActive } : link
            )
          }), false, 'togglePayLinkStatus'),
        
        // UI state
        isLoading: false,
        setLoading: (loading) => set({ isLoading: loading }, false, 'setLoading'),
        
        // Notifications
        notifications: [],
        
        addNotification: (notification) =>
          set((state) => ({
            notifications: [{
              ...notification,
              id: crypto.randomUUID(),
              timestamp: new Date()
            }, ...state.notifications]
          }), false, 'addNotification'),
          
        removeNotification: (id) =>
          set((state) => ({
            notifications: state.notifications.filter(n => n.id !== id)
          }), false, 'removeNotification'),
      }),
      {
        name: 'unykorn-app-store',
        partialize: (state) => ({
          user: state.user,
          activities: state.activities,
          payLinks: state.payLinks
        })
      }
    ),
    { name: 'UnykornAppStore' }
  )
)