
# Following libraries have been used in this project
library(shiny)
library(tidyverse)
library(dplyr)
library(ggplot2)
library(plotrix)
library(dplyr)
library(plotly)
library(shinythemes)
library(shinyalert)

# Reading the dataset
vis_ufo_data <- read_csv("combined_final_data.csv")


#code for generating the map

city <- vis_ufo_data$city # vector for cities
latitude <- vis_ufo_data$city_latitude   # vector for latitude
longitude <- vis_ufo_data$city_longitude  # vector for longitude
decade <- vis_ufo_data$Decade   # vector for decade
date <- vis_ufo_data$Date  # vector for date

df_map <- data.frame(city,latitude,longitude,decade,date)   # new data frame being created 



df_map2 <- na.omit(df_map)

df_map2<-df_map2[!grepl("na", df_map2$lat),]


# properties for the map being generated
geo_props = list(
  scope = "world",
  showland = TRUE,
  showsubunits = FALSE,
  landcolor = toRGB("gray10"),
  showlakes = TRUE,
  lakecolor = toRGB('white'),
  projection = list( type = 'orthographic')
)

# generating the map
ufo_map = plot_geo(df_map2,
                      lat =~latitude, lon =~ longitude,
                      marker = list(size =2, color = ~decade, opacity = 0.85)) %>%
  add_markers(text = ~paste(df_map2$city,', ',df_map2$date), hoverinfo = 'text') %>%
  config(displayModeBar = FALSE) %>%
  layout(geo = geo_props)




#----------------------------------------------------------------------------------------------

# creating a new data-frame, grouping by decade and UFO shape and getting count of each shape for each decade
time_series <- vis_ufo_data %>% group_by(Decade,UFO_Shape) %>%
  summarise(Decade = as.numeric(Decade),  count = length(UFO_Shape))

# removing duplicates
time_series <- unique((time_series))

# removing null values
time_series <- na.omit(time_series)

#filtering data based on UFO shape column
time_series <- time_series[!grepl(c("18/1/2003", "10679.50744", "2010", "23719.51193", "3830.432422", 
                                    "56136.03111"), time_series$UFO_Shape),]

#filtering data based on decade column
time_series<-time_series[!grepl("#VALUE!", time_series$Decade),]


# line plot to see number of sightings for each shape over the decades
plot1 <- time_series %>%
ggplot() +
 aes(x = Decade, y = count, colour = UFO_Shape) +
 geom_line(size = 0.65) +
 scale_fill_gradient() +
 scale_color_hue(direction = 1) +
 theme_light()  + 
  geom_point() 

# making the plot interactive using plotly
test_p <- ggplotly(plot1) %>%
  layout(
    title = "UFO shapes over the years", yaxis = list(title="Number of Sightings")
  ) 


#------------------------------------------------------------------------------------------------------------

# creating a new data-frame for pie-chart, grouping by UFO shape and getting the count of each shape
pie_chart <- vis_ufo_data %>% group_by(UFO_Shape) %>%
  summarise(  count = length(UFO_Shape))


#------------------------------------------------------------------------------------------------------------

# creating a new data frame, grouping by decade and country, getting count of each time a country name occurs, along with per capita GDP
final_plots <- vis_ufo_data %>% group_by(Decade,country) %>%
  summarise(count = length(country), GDP = GDP_per_Capita)

final_plots <- na.omit(final_plots) # removing null values

final_plots <- unique((final_plots)) # removing duplicates

temp_df <- final_plots %>% filter(Decade == '2020') # data frame to store data for 2020's decade

temp_df <- subset(temp_df, select = c(country,GDP))  # extracting country and GDP columns

# creating a new data frame, adding a new column having per capita GDP of each country in the 2020's
final_plots2 <- merge(final_plots,temp_df, by = 'country',all.x = TRUE) 

#renaming columns
colnames(final_plots2)[4] = 'GDP'
colnames(final_plots2)[5] = 'GDP_2020'

#scatter plot for countries having more than 55 sightings in a decade
top_10_scatter <- final_plots %>%
 filter(count >= 55L) %>%
 ggplot() +
 aes(x = Decade, y = count, colour = country, text = paste("Country: ",country,
                                                           "<br> GDP per Capita: $",GDP)) +
 geom_point(shape = "circle", size = 1.5) +
 scale_color_hue(direction = 1) +
 theme_minimal()

# making plot interactive using plotly
tens <- ggplotly(top_10_scatter, tooltip = 'text') %>%
  layout(
    title = "Decade vs Number of Sightings", yaxis = list(title="Number of Sightings")
  ) 



#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------


# Start of ui code
ui<- fluidPage(
  
 
  useShinyalert(), # shiny alert tag
  
  theme = shinythemes::shinytheme("darkly"),  # setting theme for the app
  
  # heading panel
  titlePanel(
    wellPanel(h1("ANALYSING UFO SIGHTINGS OVER THE PAST CENTURY",align = "center"))),
  # introduction panel
  fluidRow(wellPanel(
    tags$h3("The idea of life from other worlds visiting our planet from far corners of deep space has always captivated millions of people around the globe. The topic of UFO sightings has come into the limelight again owing to large number of unexplained events occurring in the past few years. This project aims to analyze the UFO sighting data going back nearly a century and draw insights from the same.")
  )),
  
  # first section
  fluidRow(wellPanel(
    tags$h2("MAPPING UFO SIGHTINGS")
  )),
  
  
  fixedRow(column(width=9,wellPanel(plotlyOutput('map',height = 750,width = 750)),align = 'center'), # Output
           column(width =3, fixedRow(wellPanel(tags$h3("The UFO sightings around the world are shown in the globe, to the left. This shows the location of every recorded UFO 
           sighting since the 1930’s. Hovering your cursor over a location will give you the name of the location along with the date of sighting. As evident from the locations
           plotted on the globe, the majority of the UFO sightings around the world are in just one particular nation - The United States of America. 
           There are also a large number of sightings in Canada, United Kingdom, Australia and India. The continent with the least number of sigthings is Africa.
            The sightings have been colour co-ordinated according to the decade, in which the sighting has occured. Darker the shade of red, the more recent the sighting."
                                              ))))),
                  
  # second section
  fluidRow(wellPanel(
    tags$h2("MOST COMMON UFO SHAPES AND TRENDS IN SHAPES OVER THE DECADES")
  )),
  
  fluidRow(  column(width = 5, height =5, 
                    wellPanel( plotlyOutput('viz2',), offset = 3)    # Output
                    
  ),
  
  column(width = 2,
         fixedRow(
           
           wellPanel(tags$h4("1. The pie chart on the left shows the percantage distribution of each observed shape(click on pie chart for more details)."),
                     tags$h4("2. The plot on the right shows the count of each shape according to deacde and the most observed shape in each decade(hover on the graph for more details, click in the legend to view individual plot for a particular shape.)"))
         )),
  
  column(width = 5, height =5, 
         wellPanel( plotlyOutput('viz3')) # Output
  )),
  
  # third section
  fluidRow(wellPanel(
    tags$h1("RELATIONSHIP BETWEEN NUMBER OF SIGHTINGS AND ECONOMIC PROSPERITY")
  )),
  
  
  fluidRow(
    column(width = 9, 
           wellPanel(plotlyOutput('viz4'))), # Output
    
    column(width = 3,
        wellPanel(tags$h3("The plot on the left shows the UFO sightings for those countries where the number of sigthings is more than 55 in a given decade. This plot also displays the countires with most cumulative sightings over the given time period. 
                          Hovering over a particular will give the information regarding the per capita GDP of that country. There seems to trend here that as the per capita GDP of a country increase so does the number of sightings. ")))
  ),
  
  
  # Creating the slider to change the range based on per capita GDP of a country in 2020's and generate a plot accordingly
  fluidRow(
    column(9,wellPanel(
      fixedRow(
        sliderInput("sliderrange",
                    label = h3("GDP per Capita (in 2020's)"), # slider Title
                    min =0, max = 50000, value =c(0,5000), width = '300'

        )
      )
    ,



    
           fixedRow(plotlyOutput('viz5')))  # Output
    
    
),
    
column(width = 3,
       wellPanel(tags$h3("The above plot isn't able to convey the information effectively as the data is heavily skewed towards one nation, United States. In the plot to the immediate left, 
                         the number of sightings have been fixed in the range of 10 to 500 sightings per decade.  You can adjust the GDP per capita range to view countries at different  
                          income levels and see the relationship between number of sightings and per capita GDP of a country. There seems to be co-relation between the 
                         number of sigthings and economic propserity of a country. As a country gets richer, the number of UFO sightings increase though co-relation
                         might not be causation.")))
  )
  
  
  )


#Start of the server code
server <- function(input, output,session) {
  
  shinyalert("Welcome", "Welcome to the UFO Dashboard! In this application we will analysing UFO sigthing data recorded over the past Century.", type = "info")
  
  # rendering the map
  output$map <- renderPlotly(ufo_map)
  
  
  # generating a pie chart using plotly and rendering the output
  output$viz2 <- renderPlotly({pie1 <- plot_ly(pie_chart, labels = ~UFO_Shape, values = ~count, type = 'pie', textinfo='label+percent',showlegend = FALSE)
                                pie1<- pie1 %>% filter(!(UFO_Shape %in% c("18/1/2003", "10679.50744", "2010", "23719.51193", "3830.432422",
                                                                         "56136.03111")) | is.na(UFO_Shape)) %>%
                                  layout(title = 'UFO Shapes',
                                         xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                                         yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))})
  
  # rendering line chart
  output$viz3 <- renderPlotly(test_p) 
  
  # rendering static scatter plot
  output$viz4 <- renderPlotly(tens)
  
  # scatter plot for countries having more than 10 but less than 500 sightings in a decade 
  data_gdp <- reactive({
    final_plots2 %>% filter(count >= 10L & count <= 500L) %>%
      filter(GDP_2020 >= input$sliderrange[1] & GDP_2020 <= input$sliderrange[2]) %>% # reactive variable
      ggplot() +
      aes(x = Decade, y = count, colour = country, text = paste("Country: ",country,
                                                                "<br> GDP per Capita: $",GDP)) +
      geom_point(shape = "circle", size = 1.5) +
      scale_color_hue(direction = 1) +
      theme_minimal()
  })
  
  
  # rendering the plot created above
  output$viz5 <- renderPlotly(
    
    ggplotly(data_gdp()) %>%
      layout(
        title = "Decade vs Number of Sightings", yaxis = list(title="Number of Sightings")
      ) 
  )
        
}

shinyApp(ui = ui, server = server)


# References

#1. Cumulative. (n.d.). Plotly.com. Retrieved October 31, 2022, from https://plotly.com/ggplot2/cumulative-animations/

#2. Convert Discrete Factor to Continuous Variable | Categorical Data | as.character() & as.numeric(). (n.d.). Www.youtube.com. Retrieved October 31, 2022, from https://www.youtube.com/watch?v=JTNORI2BnZQ

#3. Shiny - Application layout guide. (n.d.). Shiny.rstudio.com. https://shiny.rstudio.com/articles/layout-guide.html

#4. Scatter. (n.d.). Plotly.com. Retrieved October 31, 2022, from https://plotly.com/r/scatter-plots-on-maps/

#5. Shiny - column. (n.d.). Shiny.rstudio.com. Retrieved October 31, 2022, from https://shiny.rstudio.com/reference/shiny/0.14/column.html

#6. Hover. (n.d.). Plotly.com. https://plotly.com/r/hover-text-and-formatting/

#7. Setting. (n.d.). Plotly.com. Retrieved October 31, 2022, from https://plotly.com/r/setting-graph-size/

#8. Pie Charts. (n.d.). Plotly.com. https://plotly.com/python/pie-charts/

#9. shinythemes. (2022, August 18). GitHub. https://github.com/rstudio/shinythemes

#10. Sievert, C. (n.d.). 4 Maps | Interactive web-based data visualization with R, plotly, and shiny. In plotly-r.com. Retrieved October 31, 2022, from https://plotly-r.com/maps.html

#11. R Maps: Beautiful Interactive Choropleth & Scatter Maps with Plotly. (n.d.). Www.youtube.com. Retrieved October 31, 2022, from https://www.youtube.com/watch?v=RrtqBYLf404&t=286s


