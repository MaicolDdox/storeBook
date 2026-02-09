<template>
  <div class="relative overflow-hidden rounded-2xl bg-slate-200">
    <Swiper
      :modules="[Autoplay, Pagination, Navigation]"
      :slides-per-view="1"
      :loop="true"
      :autoplay="{ delay: 5000, disableOnInteraction: false }"
      :pagination="{ clickable: true }"
      :navigation="true"
      class="hero-swiper"
    >
      <SwiperSlide v-for="(slide, index) in slides" :key="index">
        <div class="relative aspect-[21/9] min-h-[200px] w-full sm:aspect-[3/1] sm:min-h-[280px]">
          <img
            v-if="slide.image"
            :src="slide.image"
            :alt="slide.alt"
            class="absolute inset-0 h-full w-full object-cover"
          />
          <div
            v-else
            class="flex h-full w-full items-center justify-center bg-gradient-to-br from-slate-300 to-slate-400"
          >
            <span class="text-lg font-semibold text-white/80">{{ slide.alt }}</span>
          </div>
          <div
            v-if="slide.title || slide.subtitle"
            class="absolute inset-0 flex flex-col items-center justify-center bg-slate-900/30 p-6"
          >
            <h2 v-if="slide.title" class="text-2xl font-extrabold text-white sm:text-3xl">
              {{ slide.title }}
            </h2>
            <p v-if="slide.subtitle" class="mt-2 text-base text-white/90 sm:text-lg">
              {{ slide.subtitle }}
            </p>
          </div>
        </div>
      </SwiperSlide>
    </Swiper>
  </div>
</template>

<script setup>
import { Swiper, SwiperSlide } from 'swiper/vue'
import { Autoplay, Pagination, Navigation } from 'swiper/modules'
import 'swiper/css'
import 'swiper/css/pagination'
import 'swiper/css/navigation'

// Replace these images by adding files to /public/images/hero/ and updating this array.
// Example: slide-1.jpg, slide-2.jpg, slide-3.jpg in /public/images/hero/
// Then use: { image: '/images/hero/slide-1.jpg', alt: 'Welcome', title: '...', subtitle: '...' }
// Until then, image is empty and a neutral placeholder gradient is shown.
const slides = [
  {
    image: '/imagenes/hero/1StoreBook.png',
    alt: 'Welcome to StoreBook',
    title: 'Welcome to StoreBook',
    subtitle: 'Discover your next favorite read from our curated collection.',
  },
  {
    image: '',
    alt: 'New arrivals',
    title: 'New Arrivals',
    subtitle: 'Explore our latest additions to the catalog.',
  },
  {
    image: '',
    alt: 'Browse the catalog',
    title: 'Browse the Catalog',
    subtitle: 'Find books across all genres and categories.',
  },
]
</script>

<style scoped>
.hero-swiper :deep(.swiper-button-prev),
.hero-swiper :deep(.swiper-button-next) {
  color: white;
}
.hero-swiper :deep(.swiper-pagination-bullet) {
  background: white;
  opacity: 0.6;
}
.hero-swiper :deep(.swiper-pagination-bullet-active) {
  opacity: 1;
}
</style>
