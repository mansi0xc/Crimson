"use client"
import { useEffect, useState } from "react"
import { MapContainer, TileLayer, Marker, Popup } from "react-leaflet"
import L from "leaflet"
import "leaflet/dist/leaflet.css"
import { useGeolocation } from "../hooks/useGeolocation"
interface CampLocation {
  lat: number;
  long: number;
  name?: string;
  city?: string;
}

// Custom marker icons

const userIcon = new L.Icon({
  iconUrl: "https://cdn-icons-png.flaticon.com/512/484/484185.png",
  shadowUrl: "https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png",
  iconSize: [38, 38],
  iconAnchor: [12, 48],
  popupAnchor: [1, -34],
  shadowSize: [54, 38],
})

const locationIcon = new L.Icon({
  iconUrl: "https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-red.png",
  shadowUrl: "https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png",
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
  shadowSize: [41, 41],
})

export default function Map({ camps = [] }: { camps: CampLocation[] }) {
  const { location, isLoading, error } = useGeolocation();
  
 

if (isLoading) {
  return (
    <div className="flex h-full items-center justify-center bg-muted">
      Loading...
    </div>
  )
}

  if (error) {
    return (
      <div className="flex h-full items-center justify-center bg-muted">
        <div className="text-lg text-destructive">{error}</div>
      </div>
    )
  }

  

  return (
    <div className="h-full w-full rounded-lg overflow-hidden">
      {location!==null }
      <MapContainer
        center={[location?.latitude ?? 20.5937, location?.longitude ?? 78.9629]}
        zoom={12.9}
        maxZoom={24}
        minZoom={4}
        scrollWheelZoom={true}
        style={{ height: "100%", width: "100%", borderRadius: "inherit", zIndex: 0 }}
      >
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
          url="https://api.maptiler.com/maps/streets-v2-light/256/{z}/{x}/{y}.png?key=GX8ZuDo9kiizn4B8zLLZ"
        />

        {/* User location marker */}
        <Marker position={[location?.latitude ?? 20.5937, location?.longitude ?? 78.9629]} icon={userIcon}>
          <Popup>
            <div className="font-semibold">Your Location</div>
          </Popup>
        </Marker>

        {/* Other location markers */}
        {camps.map((location, index) => (
          <Marker
            key={`${location?.lat}-${location?.long}-${index}`}
            position={[location?.lat ?? 20.5937, location?.long ?? 78.9629]}
            icon={locationIcon}
          >
            <Popup>
              <div>
                {location.name ? (<>
                  <div className="font-semibold mb-1">{location?.name}</div>
                  <div className="font-semibold mb-1">City:{location?.city}</div>
                </>
                 
                  
                ) : (
                  <div>Location {index + 1}</div>
                )}
              </div>
            </Popup>
          </Marker>
        ))}
      </MapContainer>
    </div>
  )
}