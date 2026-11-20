# Customer Churn in KNIME: click-by-click guide

This guide is written for the KNIME window you have open: the **classic layout**, with the Node Repository at the bottom left, the canvas in the middle, and Console at the bottom right.

Some KNIME 5 node settings windows look modern (rounded buttons: *Apply*, *Apply and Execute*, *Discard*). Others look old (buttons: *OK*, *Apply*, *Cancel*). Both work the same way. Where they differ, both are named.

---

## Part 0: The 6 basic moves (used in every step)

Every step below is these moves in order. Learn them once.

### Move 1: ADD a node
1. Click in the **search box** at the top of the bottom-left panel (the panel that lists *IO, Manipulation, Views, Analytics…*).
2. Type the node name, e.g. `CSV Reader`. The list filters as you type.
3. **Press and hold** the left mouse button on the node name in the list.
4. **Drag** it onto the white canvas in the middle and release.
5. A box appears with the node's icon, a name underneath, and a little **traffic light** under that (red = not configured).
6. Clear the search box (select the text, Delete) so you're ready for the next search.

### Move 2: CONNECT two nodes
1. Every node has small **triangles**: **inputs on the left side**, **outputs on the right side**.
2. Press and hold on the **output triangle (right side)** of the earlier node.
3. Drag to the **input triangle (left side)** of the new node and release.
4. A **black line** now joins them. If it didn't stick, try again, starting exactly on the triangle.
5. *Shortcut:* if the earlier node is selected (click it once) when you **double-click** a node in the Node Repository, KNIME adds and connects it automatically.

### Move 3: CONFIGURE a node
1. **Double-click** the node on the canvas, or right-click → **Configure…**.
2. A settings window opens. Change only what the step tells you.
3. Save the settings:
   - Modern window: click **Apply**.
   - Old window: click **OK**.
4. The traffic light turns **yellow** (configured, not yet run).

### Move 4: RUN (execute) a node
1. **Right-click** the node → **Execute**. You can also select it and press **F7**, or click **Apply and Execute** in a modern window.
2. Wait. The light turns **green** when done. Under emulation this can take 5–30 seconds.
3. **Red light or a ⚠ icon** means an error. Hover the mouse over the node to read the message, then re-open its settings (Move 3).

### Move 5: LOOK at the result
1. **Right-click** the node.
2. Choose the **last item(s)** in the menu. The table output is usually named **"Filtered table"**, **"Output table"**, **"File Table"** or similar, with a table icon.
3. A table window opens. Check the row count shown in its title or status line, then close it.
4. For nodes that make charts or reports (Statistics, Histogram, Scorer, Decision Tree to Image): right-click → **Open View** (or the view item at the bottom of the menu).

### Move 6: SAVE
- Press **Ctrl+S** often. Do this after every few steps.

---

## Part A: Data cleaning (first PDF)

### A1. Create the workflow
*(You already have one open called `Customer_Churn_ARIS…`. You can use it. Skip to A2.)*
1. **File → New…**
2. Choose **New KNIME Workflow** → **Next**.
3. Name: `Churn` → **Finish**.
4. An empty canvas tab opens.

### A2. CSV Reader: load the data
1. **Add:** search `CSV Reader` → drag it onto the left side of the canvas.
2. **Configure:** double-click it.
3. Find the file setting (a field with a **Browse…** button; the section may be called *Input location* or *Source*).
   - If there's a "read from"/file-system dropdown, set it to **Local File System**.
   - Click **Browse…**. In the file window, type this into the path box (or navigate there):
     `/home/knime/data/customer_churn_dataset.csv` → **Open/OK**.
4. Tick **"First row contains column names"**. In the old window it's called **"Has column header"** on the Settings tab. Leave everything else as it is.
5. Look at the **preview** at the bottom of the window:
   - You should see columns: *Customer_ID, Age, Annual_Income, Tenure_Months, Num_Purchases_Last_6M, Avg_Order_Value, Last_Purchase_Month, Subscription_Type, Churn*.
   - If the first column is called something odd like `ï»¿Customer_ID`, open the **Encoding** tab/section, choose **UTF-8**, and check again.
6. **Apply** (or **OK**).
7. **Run:** right-click → **Execute**. The light should turn green.
8. **Check:** right-click → **File Table**. You should see **101 rows**. Close the table.

### A3. Duplicate Row Filter: remove the duplicate C007
1. **Add:** search `Duplicate Row Filter` → drag it to the right of the CSV Reader.
2. **Connect:** CSV Reader's output triangle → Duplicate Row Filter's input triangle.
3. **Configure:** double-click it.
   - Under **"Choose columns for duplicates detection"** there are two lists, **Excludes** (left) and **Includes** (right).
   - Click the **«** button (move all to Excludes) so the right list is empty.
   - In the left list, click **Customer_ID** once, then click **›** (single arrow right). Includes must now contain **only Customer_ID**.
   - **Duplicate rows:** select **Remove duplicate rows**.
   - **Row chosen in case of duplicate:** select **First**.
4. Click **Apply and Execute**, or Apply then right-click → Execute.
5. **Check:** right-click → output table → **100 rows**, and only one C007.

### A4. String Manipulation: remove the "$" from Annual_Income
1. **Add:** search `String Manipulation` → drag it to the right.
   - Pick plain **String Manipulation**, not "(Multi Column)" or "(Variable)".
2. **Connect:** Duplicate Row Filter output → String Manipulation input.
3. **Configure:** double-click it.
   - Find the **Expression** box (the big text box at the bottom/center). Click in it and delete anything already there.
   - Type exactly: `removeChars($Annual_Income$, "$")`
     *(You can also double-click `removeChars(str, chars)` in the Function list, then double-click `Annual_Income` in the Column List, and type `, "$"` before the closing bracket.)*
   - At the bottom, choose **Replace Column:** and select **Annual_Income** in its dropdown.
   - **OK**.
4. **Run:** right-click → **Execute**.
5. **Check:** right-click → output table → Annual_Income shows `42,000` instead of `$42,000`.

### A5. String to Number: make Annual_Income a number
1. **Add:** search `String to Number` → drag it to the right.
   - Pick plain **String to Number**, not the PMML version.
2. **Connect:** String Manipulation output → String to Number input.
3. **Configure:** double-click it.
   - Column selection: Excludes / Includes lists. Click **«** to clear Includes, then move **only Annual_Income** to **Includes** with **›**.
   - **Decimal separator:** `.`  (a period)
   - **Thousands separator:** `,`  (a comma; type it if the box is empty)
   - **Type:** Number (Double)
   - Leave **"Accept type suffix"** and **"Fail on error"** unticked.
   - **Apply**
4. **Run:** right-click → **Execute**.
5. **Check:** right-click → output table.
   - Annual_Income now shows numbers like `42000.0`, and the header icon is **D** (a number) instead of **S** (text).
   - Only about **3 rows show 0**. If lots of rows show **?**, go back to A4 and change the expression to `removeChars($Annual_Income$, "$ ")` (with a space after the $), then re-run A4 and A5.

### A6. Rule Engine: change income 0 to "missing"
1. **Add:** search `Rule Engine` → drag it to the right.
   - Pick plain **Rule Engine**, not "Rule Engine (Dictionary)" or "Rule-based Row Filter".
2. **Connect:** String to Number output → Rule Engine input.
3. **Configure:** double-click it.
   - In the **Expression** box there may be grey example lines starting with `//`. They're comments, so you can leave them.
   - On a new line at the bottom, type exactly:
     `$Annual_Income$ > 0 => $Annual_Income$`
   - At the bottom, choose **Replace Column:** → **Annual_Income**.
   - **OK**.
4. **Run:** right-click → **Execute**.
5. **Check:** output table → the rows that had 0 now show **?** (missing).

### A7. Statistics: look at summary numbers
1. **Add:** search `Statistics` → drag it **below/right of the Rule Engine**.
   - Pick plain **Statistics**.
2. **Connect:** **Rule Engine** output → Statistics input.
3. **Configure:** double-click it.
   - Move **all** columns to **Includes**: click the **»** (double arrow right) button.
   - Leave other settings as they are. **Apply**.
4. **Run:** right-click → **Execute**.
5. **Look:** right-click → **Open View** (or the statistics table output).
   - Find the **"No. missing"** / **Missing** column: **Age**, **Annual_Income** and **Subscription_Type** have missing values. *(This is just for you to observe. Nothing to change.)*

### A8. Histogram: look at the shape of each column
1. **Add:** search `Histogram` → drag it near the Statistics node.
2. **Connect:** **Rule Engine** output → Histogram input. The Rule Engine output can feed several nodes at once.
3. **Configure:** double-click it.
   - Find the **Dimension** dropdown. Pick **Avg_Order_Value**. **Apply**.
4. **Run:** right-click → **Execute**.
5. **Look:** right-click → **Open View**. Avg_Order_Value is **skewed** (most bars on one side, a long tail).
   - *Optional:* change Dimension to other columns and re-run to look at each.

### A9. Missing Value: fill in the missing values
1. **Add:** search `Missing Value` → drag it to the right of the Rule Engine. Pick plain **Missing Value**, not "Missing Value (Apply)".
2. **Connect:** **Rule Engine** output → Missing Value input. Not from Statistics or Histogram.
3. **Configure:** double-click it.
   - Look at **"Treatment by Data Type"** (the old window calls it the **Default** tab).
   - **String** → choose **Most Frequent Value**
   - **Number (Integer)** → choose **Mean**
   - **Number (Float)** / **Number (Double)** → choose **Mean**
   - Leave "Treatment by Column" empty. **Apply**.
4. **Run:** right-click → **Execute**.
5. **Check:** output table → no **?** cells anywhere.

### A10. Math Formula #1: log of Avg_Order_Value
1. **Add:** search `Math Formula` → drag it to the right. Pick plain **Math Formula**, not "(Multi Column)" or "(Variable)".
2. **Connect:** Missing Value output → Math Formula input.
3. **Configure:** double-click it.
   - Clear the **Expression** box, then type: `log($Avg_Order_Value$)`
   - At the bottom select **Append Column:** and type the name `Avg_Order_Value_Log`.
   - Leave **Convert to Int** unticked. **OK**.
4. **Run** → **Check:** a new last column, **Avg_Order_Value_Log**, appears.

### A11. Math Formula #2: estimated purchases in last 6 months
1. **Add:** another `Math Formula` → drag it to the right.
2. **Connect:** Math Formula **#1** output → this new Math Formula input.
3. **Configure:**
   - Expression: `$Num_Purchases_Last_6M$*$Avg_Order_Value$`
   - **Append Column:** `Est_Purchases_Last_6M`
   - **OK**.
4. **Run** → **Check:** new column **Est_Purchases_Last_6M** appears.

### A12. Math Formula #3: make Last_Purchase_Month positive
1. **Add:** another `Math Formula` → drag it to the right.
2. **Connect:** Math Formula **#2** output → this one's input.
3. **Configure:**
   - Expression: `$Last_Purchase_Month$*-1`
   - Select **Replace Column:** → **Last_Purchase_Month**.
   - **OK**.
4. **Run** → **Check:** Last_Purchase_Month now shows positive numbers (1 to 10).

### A13. One to Many: dummy columns for Subscription_Type
1. **Add:** search `One to Many` → drag it to the right.
2. **Connect:** Math Formula **#3** output → One to Many input.
3. **Configure:** double-click it.
   - Two lists, **Available columns** (left) and **Columns to transform** (right).
   - Make sure **only Subscription_Type** is on the right. Use **«** to clear, then select Subscription_Type → **›**.
   - **"Remove included columns from output"**: leave it **unticked**.
   - **Apply**.
4. **Run** → **Check:** new columns **Basic**, **Premium**, **Standard** with 0/1 values.

### A14. Save and export submission #1
1. **Ctrl+S** to save.
2. **File → Export KNIME Workflow…**
3. In the export window:
   - **Workflow/folder to export:** make sure your churn workflow is selected (use **Select…/Browse** if it isn't).
   - **Destination / Export to file:** type
     `/home/knime/data/Customer_Churn_Cleaning_FirstName_LastName.knwf`
     with **your real first and last name**.
   - If there's an option like "Exclude data from export", leave it **unticked**, so data is included.
   - **Finish**.
4. On your Mac, open the **knime-docker → data** folder in Finder. The `.knwf` file should be there. That's the file to upload to Canvas.

---

## Part B: Churn prediction (second PDF)

Keep working in the **same workflow**, starting to the right of One to Many.

### B1. Column Filter: keep only the columns the model uses
1. **Add:** search `Column Filter` → drag it to the right of One to Many.
2. **Connect:** One to Many output → Column Filter input.
3. **Configure:** double-click it.
   - Click **«** so everything is in **Excludes**.
   - Move these **9** columns to **Includes**, one at a time (click the column → **›**):
     1. Age
     2. Annual_Income
     3. Tenure_Months
     4. Num_Purchases_Last_6M
     5. Last_Purchase_Month
     6. Subscription_Type
     7. Churn
     8. Avg_Order_Value_Log
     9. Est_Purchases_Last_6M *(the PDF misspells this one as "Est_Purchase_Last_6M")*
   - Customer_ID, Avg_Order_Value, Basic, Premium and Standard stay in **Excludes**.
   - **Apply**.
4. **Run** → **Check:** output table has exactly those **9 columns** and 100 rows.

### B2. Table Partitioner: split into training (70%) and test (30%)
1. **Add:** search `Table Partitioner` → drag it to the right.
   - If you can't find it, search `Partitioning`. It's the same node under its older name.
2. **Connect:** Column Filter output → Table Partitioner input.
3. **Configure:** double-click it.
   - **First partition type:** **Relative (%)**
   - **Relative size:** `70`
   - **Sampling strategy:** **Random**
   - Tick **Fixed random seed** and type `12`
   - **If input table is empty:** **Fail**
   - **Apply**.
4. **Run.** The node has **two output triangles**:
   - **Top** = first partition (70 rows, training data)
   - **Bottom** = second partition (30 rows, test data)
   Check: right-click → first output table = 70 rows, second = 30 rows.

### B3. Decision Tree Learner: train the model (no pruning)
1. **Add:** search `Decision Tree Learner` → drag it to the right.
   - Not the "(PMML)", "Simple Regression Tree" or "Random Forest" versions.
2. **Connect:** Table Partitioner's **TOP** output → Decision Tree Learner input.
3. **Configure:** double-click it and set:
   - **Class column:** Churn
   - **Quality measure:** Gain ratio
   - **Pruning method:** No pruning
   - **Reduced error pruning:** ticked
   - **Minimum number of records per node:** 2
   - **Number of records to store for view:** 10000
   - **Average split point:** ticked
   - **Number threads:** 8
   - **Skip nominal columns without domain information:** ticked
   - **Force root split column:** unticked
   - **Binary nominal splits:** unticked
   - **No true child strategy:** Return null prediction
   - **Missing value strategy:** Last prediction
   - **Apply** (or **OK**).
4. **Run:** right-click → **Execute** (green light).

### B4. Decision Tree to Image: picture of the tree
1. **Add:** search `Decision Tree to Image` → drag it **above-right** of the Learner.
2. **Connect:** Decision Tree Learner output (a **square-ish model port**, not a triangle) → Decision Tree to Image input.
3. **Run:** right-click → **Execute** (no settings needed).
4. **Look:** right-click → output image / **Open View**. A large, complex tree.
   - *Optional:* double-click → increase **Width** and **Height** (e.g. 3000 × 2000) for a clearer picture.

### B5. Decision Tree to Ruleset: the tree as IF/THEN rules
1. **Add:** search `Decision Tree to Ruleset` → drag it near B4.
2. **Connect:** Decision Tree Learner output → Decision Tree to Ruleset input.
3. **Run** → **Look:** right-click → output table of rules.

### B6. Decision Tree Predictor: predict churn for the test data
1. **Add:** search `Decision Tree Predictor` → drag it to the right.
2. **Connect, two connections:**
   - Decision Tree **Learner** output → Predictor's **first/top input** (the model port).
   - Table Partitioner's **BOTTOM** output → Predictor's **second/bottom input** (data).
3. **Configure:** double-click it.
   - Tick **"Append columns with normalized class distribution"**.
   - **OK**.
4. **Run** → **Check:** output table has a new column, **Prediction (Churn)**, plus probability columns. 30 rows.

### B7. Scorer: how accurate is it?
1. **Add:** search `Scorer` → drag it to the right. Pick plain **Scorer**, not "Numeric Scorer" or "Scorer (JavaScript)".
2. **Connect:** Decision Tree Predictor output → Scorer input.
3. **Configure:** double-click it.
   - **First column:** Churn
   - **Second column:** Prediction (Churn)
   - **Sorting strategy:** Insertion order
   - Reverse order / Use name prefix: unticked
   - **Missing values:** Ignore
   - **Apply**.
4. **Run** → **Look:** right-click → **Open View** (or the "Confusion matrix" and "Accuracy statistics" outputs).
5. **Write down the Accuracy**, for comparing in B9.

### B8. Change the Learner to MDL pruning
1. **Double-click** the **Decision Tree Learner** again.
2. Change **only** the **Pruning method** from *No pruning* to **MDL**. Keep everything else the same.
3. **Apply** (or **OK**).
4. The downstream nodes (Image, Ruleset, Predictor, Scorer) turn yellow, which is expected.

### B9. Re-run and compare
1. Right-click **Decision Tree Learner** → **Execute**.
2. Right-click **Decision Tree to Image** → **Execute** → view it. The tree should now be much smaller.
3. Right-click **Decision Tree to Ruleset** → **Execute** → view it. There are fewer rules.
4. Right-click **Scorer** → **Execute**. This also runs the Predictor. View the accuracy and compare it with B7.
   - *Shortcut:* the **»» (Execute all)** button in the toolbar, or **Shift+F7**, runs everything that's yellow.

### B10. Save and export submission #2
1. **Ctrl+S**.
2. **File → Export KNIME Workflow…**
3. Destination: `/home/knime/data/Customer_Churn_Prediction_FirstName_LastName.knwf` (your real name). Include data. **Finish**.
4. Check it's in **knime-docker → data** on your Mac. Upload both `.knwf` files to Canvas.

---

## Final check: what the canvas should look like

```
CSV Reader → Duplicate Row Filter → String Manipulation → String to Number → Rule Engine
Rule Engine ├→ Statistics
            ├→ Histogram
            └→ Missing Value → Math Formula (log) → Math Formula (est. purchases)
               → Math Formula (×-1) → One to Many → Column Filter → Table Partitioner
Table Partitioner (top)    → Decision Tree Learner ─┬→ Decision Tree to Image
                                                    ├→ Decision Tree to Ruleset
                                                    └→ Decision Tree Predictor (model in)
Table Partitioner (bottom) → Decision Tree Predictor (data in) → Scorer
```

All lights should be **green** before you export.

## If something goes wrong

| Problem | Fix |
|---|---|
| Can't find a node in the search | Check the spelling. Try a shorter word (e.g. `Partition`, `Duplicate`). |
| Line won't connect | Drag from exactly on the right-side triangle to exactly on the left-side triangle. Data triangles don't connect to model squares. |
| Red light / ⚠ | Hover over the node to read the error. Usually a column wasn't selected, or the previous node isn't green yet. |
| Column missing from a dropdown | The node before it hasn't been run. Execute everything before it first. |
| Want to undo | **Ctrl+Z**. To delete a node: click it → **Delete** key. |
| KNIME window feels slow | Normal under emulation. Give each step a few seconds. |
