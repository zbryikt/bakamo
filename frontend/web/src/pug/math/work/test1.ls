/*
水共有 7/5 公升, 小華喝了其中的 1/2, 請問他喝了多少公升?
水共有 7/5 公升, 小華喝了其中的 1/3, 請問剩下多少公升?
飲料 1 瓶 2 公升, 共有 3 瓶, 小華喝了其中的 1/3, 請問他喝了多少瓶??
飲料 1 瓶 2 公升, 共有 3 瓶, 小華喝了其中的 1/3, 請問他喝了多少公升??
飲料 1 瓶 2 公升, 共有 3 瓶, 小華喝了其中的 1/3, 請問剩下多少瓶??
飲料 1 瓶 2 公升, 共有 3 瓶, 小華喝了其中的 1/3, 請問剩下多少公升??
飲料 1 瓶 2 公升, 共有 3 瓶, 小華喝了其中的 1/3, 小明又喝了剩下的 1/2, 請問剩下多少瓶?
飲料 1 瓶 2 公升, 共有 3 瓶, 小華喝了其中的 1/3, 小明又喝了剩下的 1/2, 請問剩下多少公升?
*/

items = 
  * item: \飲料, quantifier: \罐, measure: \毫升
  * item: \蛋糕, quantifier: \塊, measure: \公克
  * item: \餅乾, quantifier: \塊, measure: \公克
names = <[小明 小華 小霞 小霏 小安 小駿 小玉 小遙]>

generate = ->

  sets = [
    Math.floor(2 * Math.random!)
    Math.floor(2 * Math.random!)
    Math.floor(2 * Math.random!)
    Math.floor(2 * Math.random!)
    Math.floor(2 * Math.random!)
  ]

  {item, quantifier, measure} = items[Math.floor(Math.random! * items.length)]
  pu1 = Math.ceil(Math.random! * 20)
  pu2 = Math.ceil(Math.random! * 20)
  per-unit = "#pu1/#pu2"
  count = Math.ceil(Math.random! * 10)
  names.sort (a,b) -> return Math.round(Math.random! * 2) - 1
  name1 = names.0
  name2 = names.1
  name3 = if Math.random! > 0.5 => name1 else name2

  take1 = {}
  take1.quantifier = if sets.0 == 1 => quantifier else (if Math.random! > 0.5 => quantifier else measure)
  take1.tp2 = Math.ceil(Math.random! * 20)
  take1.tp1 = Math.floor(take1.tp2 * Math.random!)
  take1.quantity = "#{take1.tp2}/#{take1.tp1}"
  if take1.quantifier == \measure => if take1.tp2 / take1.tp1 > count * per-unit => return false
  else if take1.quantifier == \quantity => if take1.tp2 / take1.tp1 > count => return false
  take1.percent = "#{take1.tp1}/#{take1.tp2}"

  take2 = {}
  take2.quantifier = if sets.0 == 1 => quantifier else (if Math.random! > 0.5 => quantifier else measure)
  take2.tp2 = Math.ceil(Math.random! * 20)
  take2.tp1 = Math.floor(take1.tp2 * Math.random!)
  take2.quantity = "#{take2.tp2}/#{take2.tp1}"
  if take2.quantifier == \measure =>
    if take2.tp2 / take2.tp1 > count * per-unit => return false
  else if take2.quantifier == \quantity =>
    if take2.tp2 / take2.tp1 > count => return false
  take2.percent = "#{take2.tp1}/#{take2.tp2}"

  set1 = [
    "#{item}1#{quantifier}#{per-unit}#{measure}, 共有#{count}#{quantifier}"
    "這邊有#{count}#{quantifier}#{item}"
  ]

  set2 = [
    "#{name1}拿了其中的#{take1.percent}"
    "#{name1}拿了其中的#{take1.quantity}#{take1.quantifier}"
  ]

  set3 = [
    [
      "#{name2}又跟#{name1}分走了#{take2.percent}"
      "#{name2}又跟#{name1}分走了#{take2.quantity}#{take2.quantifier}"
    ],
    [
      "#{name2}又拿了剩餘的#{take2.percent}"
      "#{name2}又拿了剩餘的#{take2.quantity}#{take2.quantifier}"
    ]
  ]

  set4 = [
    "請問#{name3}最後拿到多少#{measure}"
    "請問#{name3}最後拿到多少#{quantifier}#{item}"
  ]

  ret = [
    set1[sets.0]
    set2[sets.1]
    set3[sets.2][sets.3]
    set4[sets.4]
  ].join("，") + "？"

  return ret

for i from 0 til 10 =>
  ret = generate!
  console.log ret
