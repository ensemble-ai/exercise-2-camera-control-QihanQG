# Peer-Review for Programming Exercise 2 #

## Description ##

For this assignment, you will be giving feedback on the completeness of assignment two: Obscura. To do so, we will give you a rubric to provide feedback. Please give positive criticism and suggestions on how to fix segments of code.

You only need to review code modified or created by the student you are reviewing. You do not have to check the code and project files that the instructor gave out.

Abusive or hateful language or comments will not be tolerated and will result in a grade penalty or be considered a breach of the UC Davis Code of Academic Conduct.

If there are any questions at any point, please email the TA.   

## Due Date and Submission Information
See the official course schedule for due date.

A successful submission should consist of a copy of this markdown document template that is modified with your peer review. This review document should be placed into the base folder of the repo you are reviewing in the master branch. The file name should be the same as in the template: `CodeReview-Exercise2.md`. You must also include your name and email address in the `Peer-reviewer Information` section below.

If you are in a rare situation where two peer-reviewers are on a single repository, append your UC Davis user name before the extension of your review file. An example: `CodeReview-Exercise2-username.md`. Both reviewers should submit their reviews in the master branch.  

# Solution Assessment #

## Peer-reviewer Information

* *name:* Simon Gooden
* *email:* sdgooden@ucdavis.edu

### Description ###

For assessing the solution, you will be choosing ONE choice from: unsatisfactory, satisfactory, good, great, or perfect.

The break down of each of these labels for the solution assessment.

#### Perfect #### 
    Can't find any flaws with the prompt. Perfectly satisfied all stage objectives.

#### Great ####
    Minor flaws in one or two objectives. 

#### Good #####
    Major flaw and some minor flaws.

#### Satisfactory ####
    Couple of major flaws. Heading towards solution, however did not fully realize solution.

#### Unsatisfactory ####
    Partial work, not converging to a solution. Pervasive Major flaws. Objective largely unmet.


___

## Solution Assessment ##

### Stage 1 ###

- [x] Perfect
- [ ] Great
- [ ] Good
- [ ] Satisfactory
- [ ] Unsatisfactory

___
#### Justification ##### 
Camera moves perfectly on top of the the Vessel, and a cross is drawn on the center of the screen

___
### Stage 2 ###

- [x] Perfect
- [ ] Great
- [ ] Good
- [ ] Satisfactory
- [ ] Unsatisfactory

___
#### Justification ##### 
Autoscroll scrolls perfectly, and draws a box correctly bound to where the player can and cant move. All variables work as intended.

___
### Stage 3 ###

- [x] Perfect
- [ ] Great
- [ ] Good
- [ ] Satisfactory
- [ ] Unsatisfactory

___
#### Justification ##### 
Position lock and lerp smoothing function perfectly under any velocity. Leash is never exceeded and catch-up speed is always uniform. Camera is also incredibly smooth and cross is drawn. All variables like Follow speed, Catchup speed, and leash distance function as intended.
___ 
### Stage 4 ###

- [x] Perfect
- [ ] Great
- [ ] Good
- [ ] Satisfactory
- [ ] Unsatisfactory

___
#### Justification ##### 
Lerp smoothing target focus works exactly as intended and like the last stage is also very smooth and draws a cross in the middle of the screen. All variables work as intended.
___
### Stage 5 ###

- [x] Perfect
- [ ] Great
- [ ] Good
- [ ] Satisfactory
- [ ] Unsatisfactory

___
#### Justification ##### 
Overall functions perfectly as described. The one smallest issue I could find is that when boosting on the outer edges the vessel would be pushed back to the middle between the out and inner boxes, however everything else works flawlessly. The 2 boxes are drawn as they should, and the camera only moves when the vessel exits the inner box. Additionally the student uses the push ratio in a much simpler way than I initially integrated it into my own project, and just simply applies it to move_speed.x and move_speed.z if it's touching the border.
https://github.com/ensemble-ai/exercise-2-camera-control-QihanQG/blob/e764f058fe11b03e73a7256ede8059bfeaa2614f/Obscura/scripts/pushzone.gd#L76
Otherwise its just applied to the move_speed variable as a whole which is quite intuitive!
One small note I did notice is that the student is taking variables for box width and height and inner box width and height as variables and using them as the standard instead of the corner variables assigned, however when testing inputting x and y coordinates also functions perfectly in drawing the boxes
https://github.com/ensemble-ai/exercise-2-camera-control-QihanQG/blob/e764f058fe11b03e73a7256ede8059bfeaa2614f/Obscura/scripts/pushzone.gd#L6-L10
___
# Code Style #


### Description ###
Check the scripts to see if the student code adheres to the GDScript style guide.

If sections do not adhere to the style guide, please peramlink the line of code from Github and justify why the line of code has not followed the style guide.

It should look something like this:

* [description of infraction](https://github.com/dr-jam/ECS189L) - this is the justification.

Please refer to the first code review template on how to do a permalink.


#### Style Guide Infractions ####
https://github.com/ensemble-ai/exercise-2-camera-control-QihanQG/blob/e764f058fe11b03e73a7256ede8059bfeaa2614f/Obscura/scripts/camera_controllers/push_box.gd#L1
Here the student incorrectly uses snake case for a class name when traditionally we are supposed to use pascal case for titles, so it should be "TargetLock"
Other than this the student had virtually no infractions. The only other small error if you could even call it that, is that the Postition Lock Camera's script is called push_box.gd and is the only script in the cameracontroller file within scripts, while every other camera script is located just within scripts/
Other than this there were no other noticable mistakes that I could find.

#### Style Guide Exemplars ####

___
#### Put style guide infractures ####

___

# Best Practices #

### Description ###
Overall this student wrote inceridbly clean and functioning code! I found it very hard to find infractions since everything was written so well!

#### Best Practices Infractions ####
Besides that one small errors found in that first stage student adheres to all of the godot style guide from what I found. As a completely personal preference, I think some scripts could use a couple extra coments to help readability, but even so almost every functionality is very well documented and explained. One part that perticular shows how well explained this code is in the following
https://github.com/ensemble-ai/exercise-2-camera-control-QihanQG/blob/e764f058fe11b03e73a7256ede8059bfeaa2614f/Obscura/scripts/pushzone.gd#L95
Where the student helps mention this if statement isnt actively being used, but still shows an initial appraoch on tackling this stage of the project. Overall very strong practices and even helped me see some holes in my own project.

#### Best Practices Exemplars ####
https://github.com/ensemble-ai/exercise-2-camera-control-QihanQG/blob/e764f058fe11b03e73a7256ede8059bfeaa2614f/Obscura/scripts/camera_lead.gd#L13-L17
I think the amount of description on these comments were a great example of some of the best practices from this student. Variables like camera_drag can be somewhat tricky to understand at a first glance but the addition of a comment talking about how heavy it makes the camera makes perfect sense to anyone even outside of programming!
Consistent use of commenting like this is what helps makes code much easier to read and I found it extremely helpful.
