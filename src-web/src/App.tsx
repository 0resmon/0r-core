import './App.css'
import notify, { Toaster, ToastPosition } from 'react-hot-toast';
import useNuiEvent from './hooks/useNuiEvent'; 
import React from 'react'

function App() {
  const [pos, setPos] = React.useState<ToastPosition>('top-center');
 
  useNuiEvent('showNotify', (data) => {
      switch(data.type) {
         case "success": 
           notify.success(data.text, { position: pos })
         break;
         case "error":
          notify.error(data.text, { position: pos })
         break;
         case "emoji":
          notify(data.text,  { icon: data.icon, position: pos })
         break;
         case "setDefaultPos":
              setPos(data.pos);
         break;
         default:
           notify(data.text, { position: pos })
         break
      }
  });

  React.useEffect(() => {
       console.log("pos değiştiirldi.")
  }, [pos])
 
  return (
    <div className="App">
        <Toaster />
    </div>
  )
}

export default App
