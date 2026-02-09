import { useAuthStore } from '@/stores/auth'
import { useUiStore } from '@/stores/ui'

/**
 * Composable to guard user actions (add to cart, buy, checkout) behind authentication.
 * If not authenticated: opens LoginModal and stores intended action for after login.
 * If authenticated: executes the action immediately.
 */
export function useRequireAuthAction() {
  const authStore = useAuthStore()
  const uiStore = useUiStore()

  function executeWithAuth(actionFn, context = {}) {
    if (authStore.isAuthenticated) {
      return actionFn()
    }

    uiStore.setPendingAuthAction({
      action: actionFn,
      context,
    })
    uiStore.setLoginModalOpen(true)
  }

  return { executeWithAuth }
}
