import os
from PIL import Image, ImageDraw

def create_character_sprites():
    # Create sprites directory if it doesn't exist
    os.makedirs("sprites", exist_ok=True)
    
    # Character dimensions
    char_width, char_height = 32, 48
    
    # Colors
    skin_color = (255, 220, 177)
    hair_color = (139, 69, 19)
    shirt_color = (0, 100, 200)
    pants_color = (50, 50, 50)
    
    def create_stick_figure_sprites():
        """Create simple stick figure character sprites"""
        # Create sprite sheet: 6 frames wide (idle, walk1-4, jump)
        sprite_sheet = Image.new('RGBA', (char_width * 6, char_height), (0, 0, 0, 0))
        
        for i, frame_name in enumerate(['idle', 'walk1', 'walk2', 'walk3', 'walk4', 'jump']):
            frame = Image.new('RGBA', (char_width, char_height), (0, 0, 0, 0))
            draw = ImageDraw.Draw(frame)
            
            # Head
            draw.ellipse([12, 4, 20, 12], fill=skin_color, outline=(0, 0, 0), width=1)
            
            # Body
            draw.line([16, 12, 16, 30], fill=(0, 0, 0), width=2)
            
            # Arms and legs vary by frame
            if frame_name == 'idle':
                # Arms down
                draw.line([16, 18, 10, 25], fill=(0, 0, 0), width=2)
                draw.line([16, 18, 22, 25], fill=(0, 0, 0), width=2)
                # Legs straight
                draw.line([16, 30, 12, 44], fill=(0, 0, 0), width=2)
                draw.line([16, 30, 20, 44], fill=(0, 0, 0), width=2)
                
            elif frame_name in ['walk1', 'walk3']:
                # Arms swinging
                draw.line([16, 18, 8, 26], fill=(0, 0, 0), width=2)
                draw.line([16, 18, 24, 24], fill=(0, 0, 0), width=2)
                # One leg forward, one back
                draw.line([16, 30, 10, 44], fill=(0, 0, 0), width=2)
                draw.line([16, 30, 22, 42], fill=(0, 0, 0), width=2)
                
            elif frame_name in ['walk2', 'walk4']:
                # Arms swinging opposite
                draw.line([16, 18, 24, 26], fill=(0, 0, 0), width=2)
                draw.line([16, 18, 8, 24], fill=(0, 0, 0), width=2)
                # Legs opposite
                draw.line([16, 30, 22, 44], fill=(0, 0, 0), width=2)
                draw.line([16, 30, 10, 42], fill=(0, 0, 0), width=2)
                
            elif frame_name == 'jump':
                # Arms up
                draw.line([16, 18, 10, 14], fill=(0, 0, 0), width=2)
                draw.line([16, 18, 22, 14], fill=(0, 0, 0), width=2)
                # Legs bent
                draw.line([16, 30, 10, 38], fill=(0, 0, 0), width=2)
                draw.line([16, 30, 22, 38], fill=(0, 0, 0), width=2)
                draw.line([10, 38, 8, 42], fill=(0, 0, 0), width=2)
                draw.line([22, 38, 24, 42], fill=(0, 0, 0), width=2)
            
            # Paste frame to sprite sheet
            sprite_sheet.paste(frame, (i * char_width, 0))
        
        sprite_sheet.save("sprites/stick_figure_character.png")
    
    def create_pixel_character_sprites():
        """Create pixel art character sprites"""
        sprite_sheet = Image.new('RGBA', (char_width * 6, char_height), (0, 0, 0, 0))
        
        for i, frame_name in enumerate(['idle', 'walk1', 'walk2', 'walk3', 'walk4', 'jump']):
            frame = Image.new('RGBA', (char_width, char_height), (0, 0, 0, 0))
            draw = ImageDraw.Draw(frame)
            
            # Head
            draw.rectangle([13, 6, 19, 14], fill=skin_color)
            draw.rectangle([14, 4, 18, 8], fill=hair_color)  # Hair
            draw.point([15, 10], fill=(0, 0, 0))  # Left eye
            draw.point([17, 10], fill=(0, 0, 0))  # Right eye
            
            # Torso
            draw.rectangle([14, 14, 18, 26], fill=shirt_color)
            
            # Legs
            draw.rectangle([14, 26, 16, 38], fill=pants_color)  # Left leg
            draw.rectangle([16, 26, 18, 38], fill=pants_color)  # Right leg
            
            # Arms and leg positions vary by frame
            if frame_name == 'idle':
                draw.rectangle([12, 16, 14, 24], fill=skin_color)  # Left arm
                draw.rectangle([18, 16, 20, 24], fill=skin_color)  # Right arm
                draw.rectangle([13, 38, 17, 44], fill=(139, 69, 19))  # Feet
                
            elif frame_name in ['walk1', 'walk3']:
                draw.rectangle([11, 18, 13, 26], fill=skin_color)  # Left arm back
                draw.rectangle([19, 14, 21, 22], fill=skin_color)  # Right arm forward
                draw.rectangle([12, 38, 16, 44], fill=(139, 69, 19))  # Left foot
                draw.rectangle([16, 36, 20, 42], fill=(139, 69, 19))  # Right foot forward
                
            elif frame_name in ['walk2', 'walk4']:
                draw.rectangle([19, 18, 21, 26], fill=skin_color)  # Right arm back
                draw.rectangle([11, 14, 13, 22], fill=skin_color)  # Left arm forward
                draw.rectangle([16, 38, 20, 44], fill=(139, 69, 19))  # Right foot
                draw.rectangle([12, 36, 16, 42], fill=(139, 69, 19))  # Left foot forward
                
            elif frame_name == 'jump':
                draw.rectangle([10, 12, 12, 20], fill=skin_color)  # Left arm up
                draw.rectangle([20, 12, 22, 20], fill=skin_color)  # Right arm up
                draw.rectangle([13, 32, 17, 40], fill=(139, 69, 19))  # Feet together
            
            sprite_sheet.paste(frame, (i * char_width, 0))
        
        sprite_sheet.save("sprites/pixel_character.png")
    
    def create_silhouette_character():
        """Create silhouette character sprites"""
        sprite_sheet = Image.new('RGBA', (char_width * 6, char_height), (0, 0, 0, 0))
        
        for i, frame_name in enumerate(['idle', 'walk1', 'walk2', 'walk3', 'walk4', 'jump']):
            frame = Image.new('RGBA', (char_width, char_height), (0, 0, 0, 0))
            draw = ImageDraw.Draw(frame)
            
            # Create silhouette shape based on frame
            if frame_name == 'idle':
                # Standing silhouette
                points = [(16, 6), (18, 8), (18, 12), (20, 14), (20, 26), (18, 28), 
                         (18, 38), (20, 44), (16, 44), (12, 44), (14, 38), (14, 28), 
                         (12, 26), (12, 14), (14, 12), (14, 8)]
                draw.polygon(points, fill=(0, 50, 100))
                
            elif frame_name == 'jump':
                # Jumping silhouette with bent limbs
                points = [(16, 6), (18, 8), (18, 12), (22, 10), (22, 16), (18, 18), 
                         (18, 26), (20, 28), (20, 34), (18, 36), (16, 40), (14, 36), 
                         (12, 34), (12, 28), (14, 26), (14, 18), (10, 16), (10, 10), (14, 12), (14, 8)]
                draw.polygon(points, fill=(0, 50, 100))
            
            else:  # Walking frames
                # Walking silhouette with offset limbs
                points = [(16, 6), (18, 8), (18, 12), (20, 14), (20, 26), (18, 28), 
                         (19, 38), (21, 44), (15, 44), (11, 44), (13, 38), (14, 28), 
                         (12, 26), (12, 14), (14, 12), (14, 8)]
                draw.polygon(points, fill=(0, 50, 100))
            
            sprite_sheet.paste(frame, (i * char_width, 0))
        
        sprite_sheet.save("sprites/silhouette_character.png")
    
    # Create all character variations
    create_stick_figure_sprites()
    create_pixel_character_sprites()
    create_silhouette_character()
    print("Character sprites created successfully!")

if __name__ == "__main__":
    create_character_sprites()