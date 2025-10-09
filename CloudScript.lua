loadstring(game:HttpGet(("https://raw.githubusercontent.com/daucobonhi/Ui-Redz-V2/refs/heads/main/UiREDzV2.lua")))()
       local Window = MakeWindow({
         Hub = {
         Title = "NaoHub Roblox",
         Animation = "สคริปต์เน่าเองง..."
         },
        Key = {
        KeySystem = false,
        Title = "Key System",
        Description = "",
        KeyLink = "คีย์วางช่องใส่คีย์",
        Keys = {"nao"},
        Notifi = {
        Notifications = true,
        CorrectKey = "กำลังโหลดสคริป...",
       Incorrectkey = "คีย์ไม่ถูกต้อง",
       CopyKeyLink = "คัดลอกไปยังคลิปบอร์ดแล้ว"
      }
    }
  })

       MinimizeButton({
       Image = "🍼",
       Size = {40, 40},
       Color = Color3.fromRGB(10, 10, 10),
       Corner = true,
       Stroke = false,
       StrokeColor = Color3.fromRGB(255, 0, 0)
      })
      
------ Tab
     local Tab1o = MakeTab({Name = "99 คืนในป่า"})
     
------- BUTTON
AddButton(Tab1o, {
     Name = "RINGTA",
    Callback = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/wefwef127382/99daysloader.github.io/refs/heads/main/ringta.lua"))()
  end
  })
      AddButton(Tab1o, {
     Name = "NaoWare แปลไทย",
    Callback = function()
	 loadstring(game:HttpGet("https://raw.githubusercontent.com/Mewnaoo/Nao-Script/refs/heads/Custom/NaoHub.lua", true))()
  end
  })
    })
      AddButton(Tab1o, {
     Name = "Voidware",
    Callback = function()
	 loadstring(game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/VW-Add/refs/heads/main/newnightsintheforest.lua", true))()
  end
  })
    })
      AddButton(Tab1o, {
     Name = "คนไทย",
    Callback = function()
	 loadstring(game:HttpGet("https://raw.githubusercontent.com/MQPS7/99-Night-in-the-Forset/refs/heads/main/99v2", true))()
  end
  })