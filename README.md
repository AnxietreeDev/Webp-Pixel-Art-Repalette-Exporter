### Pixel Art Repalette Exporter
Made with Godot 4.4 by Anxietreedev, Ayrton.
A Godot program that recolors your sprites for you into every other color of your color ramp from your palette file.
Useful in situations where shader-based approaches or runtime recoloring isn't feasible or ideal for your use case. 

## **Usage:**
# Step 1: Prepare your palette.webp/png
Prepare a modified palette .webp/png for the program to read:

- 1 PIXEL PER COLOR
- MAXIMUM OF 9 COLORS PER RAMP
- EACH RAMP DELIMITED BY AT LEAST 1 TRUE BLACK PIXEL #000000
- **INCLUDING THE FIRST ONE. START THE IMG WITH AT LEAST 1 BLACK PIXEL.**
- FORMATTED AS LOSSLESS WEBP OR PNG

Example: Arrange your palette like this

![Image displaying the correct palette format](https://i.imgur.com/tKfyNPj.png)

Or like this (your ramps can cross onto new rows)

![Image displaying a different but still correct palette format](https://i.imgur.com/XlmIFmQ.png)

and upload your palette into the program.

# Step 2: Prepare your sprites for recoloring
Recolor your sprites you want to mass export into the Recolor Key Shades:
![Image displaying the recolor palette](https://i.imgur.com/abK0YXd.png)

e8eff2
cfd7dc
a7b2cb
8898ba
6a79a0
5d5f85
464a71
323959
22283f 

- **The lightest tone (e8eff2) always corresponds to the 1st color detected in your ramp.**
- Repaint the areas of the sprite you want recolored like the right in this image:

![Image displaying a correctly recolored sprite](https://i.imgur.com/H3kuKFd.png)

(Tip: open aseprite, hit shift-r, and recolor ALL your common assets you can recolor at once from a sprite atlas)

Upload your sprite or spritesheet, and a folder will be created on your desktop called Repal_Exports to hold all the recolored sprites.
Voila!

Your result should look something like the following: 

![image displaying successful image conversion](https://i.imgur.com/PwXAN8J.png)

## NOTES 

- Remember, if one of your color ramps has less colors than the Recol Key Shades you've used, those segments won't be recolored!
- See above image where the above 3rd pink ramp has only 6 colors, but the image was prepared for 7 tones, the 7th tone won't be recolored!
- For issues during image import ensure you have read-write permissions for the OS's desktop path. 
- No reported issues so far! 


This project was made during my own personal time to help assist with my personal and professional workload for sprites that required frequent adjustments but also needed to exist in many (20+) colors. Saves a lot of repeated manual recoloring and exporting.
Hope it's helpful for whoever stumbles across it. Feel free to use it as a basis for more complex image manipulation programs in GDscript.
Very fun little micro project to create over the course of my evenings in the week.

- Anxietreedev, Ayrton <3
